import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/auth/repositories/user_repository.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/routes/app_routes.dart';

class VocabDeckController extends GetxController {
  late final VocabDeckRepository _repo;
  late final StudySessionRepository _sessionRepo;
  late final UserRepository _userRepo;

  /// Thứ tự CEFR tăng dần — dùng để so sánh cấp user với cấp bộ thẻ.
  static const cefrOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  final decks = <VocabDeck>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  /// Trình độ CEFR của người dùng (vd "A2"). Rỗng = chưa rõ → không lọc.
  final userLevel = ''.obs;

  /// Cấp đang được chọn ở chip lọc tab "Khám phá". Rỗng = "Tất cả".
  final selectedLevel = ''.obs;

  /// Vị trí cấp user trong [cefrOrder]. -1 nếu chưa rõ / không hợp lệ.
  int get _userLevelIndex => cefrOrder.indexOf(userLevel.value.toUpperCase());

  /// Các cấp CEFR có bộ thẻ hệ thống mà user được phép xem (≤ trình độ user),
  /// xếp gần cấp user nhất lên trước (vd A2 → ["A2", "A1"]). Dùng dựng chip lọc.
  /// Hàng chip luôn hiện ở mọi cấp; chỉ ẩn khi rỗng (chưa tải xong / lỗi).
  List<String> get availableLevels {
    final maxIdx = _userLevelIndex;
    final present = <String>{
      for (final d in decks)
        if (d.isSystem) d.cefrLevel.toUpperCase(),
    };
    final levels = cefrOrder
        .where((l) => present.contains(l))
        .where((l) => maxIdx < 0 || cefrOrder.indexOf(l) <= maxIdx)
        .toList();
    // Gần cấp user nhất lên đầu (đồng bộ thứ tự nhóm trong VocabDeckList).
    if (maxIdx >= 0) {
      levels.sort((a, b) =>
          (maxIdx - cefrOrder.indexOf(a)).compareTo(maxIdx - cefrOrder.indexOf(b)));
    }
    return levels;
  }

  /// Đổi cấp lọc (rỗng = Tất cả). Bấm lại cấp đang chọn → bỏ lọc.
  void onSelectLevel(String level) {
    final v = level.toUpperCase();
    selectedLevel.value = (selectedLevel.value == v) ? '' : v;
  }

  /// Bộ thẻ hệ thống (owner=NULL) — tab "Khám phá".
  /// Chỉ hiển thị các cấp ≤ trình độ user (vd A2 thấy A1+A2, không thấy B1+).
  /// Nếu chưa rõ trình độ user (userLevel rỗng) thì hiển thị tất cả.
  /// Nếu user đã chọn 1 cấp ở chip lọc thì chỉ hiển thị cấp đó.
  List<VocabDeck> get systemDecks {
    final maxIdx = _userLevelIndex;
    final sel = selectedLevel.value;
    return decks.where((d) {
      if (!d.isSystem) return false;
      final lvl = d.cefrLevel.toUpperCase();
      if (sel.isNotEmpty && lvl != sel) return false; // chip lọc cấp cụ thể
      if (maxIdx < 0) return true; // chưa rõ cấp user → không lọc theo cấp
      final di = cefrOrder.indexOf(lvl);
      // Cấp lạ (di < 0) vẫn hiển thị để không nuốt mất dữ liệu.
      return di < 0 || di <= maxIdx;
    }).toList();
  }

  /// Bộ thẻ do người dùng tự tạo — tab "Bộ thẻ của tôi".
  List<VocabDeck> get myDecks =>
      decks.where((d) => !d.isSystem).toList();

  /// Tổng số thẻ đến hạn ôn (SM-2) trên tất cả bộ thẻ — điểm nhấn riêng của tab "Bộ thẻ của tôi".
  final dueToday = 0.obs;

  /// Tiến độ học per-deck (keyed theo deckId) — đổ từ cùng lệnh gọi due-cards,
  /// dùng cho mini progress trên mỗi card. Trống = chưa tải xong / lỗi.
  final progressByDeck = <String, DeckProgress>{}.obs;

  // Stats (mock — sẽ lấy từ user profile sau)
  final dayStreak = 12.obs;
  final avgMastery = 85.obs;

  // Word of the day (mock)
  final wordOfDay = 'Eloquent'.obs;
  final wordDefinition = 'Fluent or persuasive in speaking or writing.'.obs;

  @override
  void onInit() {
    super.onInit();
    _repo = VocabDeckRepository(DioClient.instance);
    _sessionRepo = StudySessionRepository(DioClient.instance);
    _userRepo = UserRepository(DioClient.instance);
    loadDecks();
  }

  Future<void> loadDecks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _loadUserLevel(); // phụ — không await, lọc danh sách cập nhật khi có kết quả
      decks.value = await _repo.getDecks();
      _loadDeckProgress(); // phụ — không await, không chặn UI danh sách
    } on DioException catch (e) {
      errorMessage.value = e.message ?? T.errorConnection.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy trình độ CEFR của user để lọc bộ thẻ hệ thống theo cấp.
  /// Lỗi/không rõ → để rỗng (hiển thị tất cả, không chặn UI).
  Future<void> _loadUserLevel() async {
    try {
      final me = await _userRepo.getMe();
      userLevel.value = me.cefrLevel ?? '';
    } catch (_) {
      userLevel.value = '';
    }
  }

  /// Gọi due-cards cho từng bộ (song song) để vừa cộng tổng `dueToday`,
  /// vừa đổ tiến độ per-deck vào `progressByDeck`. Một lệnh gọi, hai mục đích —
  /// không phát sinh request thừa. Lỗi từng bộ không làm hỏng các bộ khác.
  Future<void> _loadDeckProgress() async {
    if (decks.isEmpty) {
      dueToday.value = 0;
      progressByDeck.clear();
      return;
    }
    final results = await Future.wait(
      decks.map((d) async {
        try {
          final res = await _sessionRepo.getDueCards(d.id);
          return MapEntry(
            d.id,
            DeckProgress(
              due: res.totalDue,
              fresh: res.totalNew,
              total: d.flashcardCount,
            ),
          );
        } catch (_) {
          return MapEntry(d.id, null);
        }
      }),
    );
    final map = <String, DeckProgress>{};
    var dueSum = 0;
    for (final e in results) {
      final p = e.value;
      if (p != null) {
        map[e.key] = p;
        dueSum += p.due;
      }
    }
    progressByDeck.value = map;
    dueToday.value = dueSum;
  }

  void onStartStudy(VocabDeck deck) => Get.toNamed(AppRoutes.deckPrep, arguments: deck);

  void onPracticeWordOfDay() {}

  void onCreateDeck() => Get.toNamed(AppRoutes.createDesk);

  void onEditDeck(VocabDeck deck) => Get.toNamed(AppRoutes.createDesk, arguments: deck);

  Future<void> onDeleteDeck(VocabDeck deck) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.errorDeleteDeskTitle.tr),
        content: Text(T.errorDeleteDeskContentSimple.trParams({'title': deck.title})),
        actions: [
          AppButton(
            label: T.actionCancel,
            onPressed: () => Get.back(result: false),
            variant: AppButtonVariant.text,
            expand: false,
            height: 44,
          ),
          AppButton(
            label: T.actionDelete,
            onPressed: () => Get.back(result: true),
            variant: AppButtonVariant.dangerText,
            expand: false,
            height: 44,
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.deleteDeck(deck.id);
      await loadDecks();
      AppNotify.success(T.deckDeleted.tr, message: deck.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? (e.response!.data as Map)['message']?.toString() : null;
      AppNotify.error(T.errorDeleteFailedTitle.tr, message: msg ?? e.message ?? T.errorNetwork.tr);
    }
  }

  void onViewAll() {}
}
