import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/home/models/home_dashboard_model.dart';
import 'package:englishme/modules/home/repositories/home_repository.dart';
import 'package:englishme/modules/home/views/widgets/save_word_deck_sheet.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';
import 'package:englishme/modules/learn/repositories/api_curriculum_repository.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum HomeLoadState { idle, loading, success, error }
enum WordOfDayState { idle, loading, loaded, empty, error }

class HomeController extends GetxController {
  final HomeRepository _repo;
  final VocabDeckRepository _deckRepo;
  HomeController(this._repo, this._deckRepo);

  final loadState = HomeLoadState.idle.obs;
  final Rxn<HomeDashboardResponse> dashboard = Rxn();
  final Rxn<WordOfDayDto> dailyWord = Rxn();
  final RxString greetingLabel = T.homeGreeting.tr.obs;
  final RxBool wordSaved = false.obs;
  final RxBool wordPlaying = false.obs;
  final wordOfDayState = WordOfDayState.idle.obs;
  final wordOfDayMessage = ''.obs;

  // ----- Giáo trình: Unit đang học (để hiện ở Home) -----
  // API thật (trước đây dùng MockCurriculumRepository → gây cảm giác "dữ liệu fake" ở Home).
  final CurriculumRepository _curriculumRepo =
      ApiCurriculumRepository(DioClient.instance);
  final Rxn<CurriculumUnit> currentUnit = Rxn<CurriculumUnit>();
  // Đang tải Unit đang học — để Home hiện khung chờ thay vì nhảy banner chung
  // (trạng thái sai) trước khi có dữ liệu thật.
  final currentUnitLoading = true.obs;

  /// Fallback khi chưa có dashboard — khớp default backend (user_daily_goals.targetXp = 30).
  static const int dailyXpTargetFallback = 30;

  Worker? _tabWorker;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
    loadDashboard();
    loadWordOfDay();
    // Shell dùng IndexedStack → Home không rebuild khi quay lại tab. Lắng nghe
    // tab: mỗi lần quay về Home (index 0) refresh ngầm dashboard (XP hôm nay,
    // streak, ngày học/tuần) + Unit đang học để phản ánh tiến độ vừa học ở tab
    // khác — không bật loading toàn màn để card không bị nháy.
    final shell = ShellController.ensureRegistered();
    _tabWorker = ever<int>(shell.currentTab, (index) {
      if (index == 0) loadDashboard(silent: true);
    });
  }

  @override
  void onClose() {
    _tabWorker?.dispose();
    super.onClose();
  }

  /// Unit để hiển thị "đang học" ở Home. Ưu tiên (theo thứ tự order):
  ///   1) Unit đang học dở (in_progress)
  ///   2) Unit CHƯA hoàn thành & đã mở (available — vd Unit 3 mới mở, 0%)
  ///   3) Nếu tất cả đã hoàn thành → Unit cuối cùng (hiện 100%)
  /// KHÔNG fallback về Unit đã completed đầu danh sách (gây kẹt ở Unit 1 100%).
  /// [silent]: true khi refresh ngầm (vd quay lại tab Home) — không bật khung
  /// chờ để card không bị chớp; chỉ cập nhật dữ liệu nếu có thay đổi.
  Future<void> loadCurrentUnit({bool silent = false}) async {
    if (!silent) currentUnitLoading.value = true;
    try {
      final data = await _curriculumRepo.getLevelUnits(homeLevel);
      // Sắp theo order để "đầu tiên" đúng nghĩa là unit sớm nhất.
      final units = [...data.units]..sort((a, b) => a.order.compareTo(b.order));
      if (units.isEmpty) {
        currentUnit.value = null;
        return;
      }
      currentUnit.value = units.firstWhere(
        (u) => u.status == 'in_progress',
        orElse: () => units.firstWhere(
          // unit đã mở nhưng chưa hoàn thành (available/in_progress, bỏ completed & locked)
          (u) => !u.isLocked && !u.isCompleted,
          // tất cả đã hoàn thành → unit cuối (hiện 100%)
          orElse: () => units.last,
        ),
      );
    } catch (_) {
      if (!silent) currentUnit.value = null;
    } finally {
      currentUnitLoading.value = false;
    }
  }

  /// [silent]: true khi refresh ngầm (vd quay lại tab Home sau khi học) — không bật
  /// loading/error toàn màn để tránh nháy skeleton; chỉ cập nhật số liệu (XP hôm nay,
  /// streak…) nếu lấy được dữ liệu mới. Giữ nguyên dashboard cũ nếu refresh lỗi.
  Future<void> loadDashboard({bool silent = false}) async {
    try {
      if (!silent) loadState.value = HomeLoadState.loading;
      dashboard.value = await _repo.getDashboard();
      loadState.value = HomeLoadState.success;
    } catch (_) {
      if (!silent) loadState.value = HomeLoadState.error;
    }
    // Tải Unit đang học sau khi đã biết cấp độ của user.
    await loadCurrentUnit(silent: silent);
  }

  Future<void> reloadDashboard() async {
    await Future.wait([
      loadDashboard(),
      loadWordOfDay(forceRefresh: true),
    ]);
  }

  Future<void> loadWordOfDay({bool forceRefresh = false}) async {
    try {
      wordOfDayState.value = WordOfDayState.loading;
      wordOfDayMessage.value = '';
      final result = await _repo.getWordOfDay(forceRefresh: forceRefresh);
      dailyWord.value = result;
      wordSaved.value = false;
      wordOfDayState.value =
          result == null ? WordOfDayState.empty : WordOfDayState.loaded;
      if (result == null) {
        wordOfDayMessage.value =
            'Làm placement test để nhận từ vựng mỗi ngày theo level của bạn.';
      }
    } catch (_) {
      wordOfDayState.value = WordOfDayState.error;
      wordOfDayMessage.value =
          'Không tải được từ vựng mỗi ngày. Vui lòng thử lại.';
    }
  }

  // ----- User -----
  String get userName {
    final name = dashboard.value?.user.fullName;
    return (name != null && name.isNotEmpty) ? name : T.homeDefaultName.tr;
  }

  String get userLevel => dashboard.value?.user.cefrLevel ?? '—';

  // ----- Daily XP -----
  int get currentXp => dashboard.value?.dailyStats.xpToday ?? 0;
  // Mục tiêu lấy từ backend (user_daily_goals.targetXp); fallback 30 khi chưa có dashboard.
  int get targetXp => dashboard.value?.dailyStats.xpGoal ?? dailyXpTargetFallback;
  double get xpProgress =>
      targetXp > 0 ? (currentXp / targetXp).clamp(0.0, 1.0) : 0.0;

  // ----- Quick stats -----
  int get streakDays => dashboard.value?.dailyStats.currentStreak ?? 0;
  int get xpToday => dashboard.value?.dailyStats.xpToday ?? 0;
  int get xpWeek => dashboard.value?.dailyStats.xpWeek ?? 0;
  int get activeDaysThisWeek => dashboard.value?.dailyStats.activeDaysThisWeek ?? 0;

  // ----- Due cards (P5) -----
  /// Số thẻ flashcard tới hạn ôn hôm nay (cá nhân hóa SM-2 → Home).
  int get dueCardCount => dashboard.value?.dailyStats.dueCardCount ?? 0;

  /// Mở study session để ôn thẻ tới hạn.
  void onReviewDueCards() => Get.toNamed(AppRoutes.flashcards);

  // ----- Continue learning -----
  ContinueLearning? get continueLearning => dashboard.value?.continueLearning;

  /// Cấp độ dùng để mở giáo trình theo Unit (chuẩn hoá, fallback A1).
  String get homeLevel {
    final lv = dashboard.value?.user.cefrLevel;
    if (lv == null || lv.trim().isEmpty || lv == '—') return 'A1';
    return lv;
  }

  // ----- Word of day -----
  WordOfDayDto? get wordOfDay => dailyWord.value;

  // ----- Recommendations -----
  List<HomeRecommendation> get recommendations =>
      dashboard.value?.recommendations ?? const [];

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingLabel.value = T.homeGreetingMorning.tr;
    } else if (hour < 18) {
      greetingLabel.value = T.homeGreetingAfternoon.tr;
    } else {
      greetingLabel.value = T.homeGreetingEvening.tr;
    }
  }

  Future<void> onListenWordOfDay() async {
    if (wordPlaying.value) return;
    final word = wordOfDay?.word;
    if (word == null || word.trim().isEmpty) return;
    wordPlaying.value = true;
    try {
      await Get.find<TtsService>().speak(word);
    } finally {
      wordPlaying.value = false;
    }
  }

  /// CEFR mặc định để tạo bộ thẻ khi lưu từ: ưu tiên level của từ, fallback level user.
  String get _saveCefr {
    final lv = wordOfDay?.level;
    if (lv != null && lv.trim().isNotEmpty) return lv.trim().toUpperCase();
    return homeLevel;
  }

  /// Bấm "Lưu từ" → mở bottom sheet chọn bộ thẻ (chỉ bộ của user, không phải hệ thống).
  void onAddWordToFlashcard() {
    final word = wordOfDay;
    if (word == null) return;
    Get.bottomSheet<void>(
      SaveWordDeckSheet(word: word.word, suggestedCefr: _saveCefr),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// Tải bộ thẻ user có thể lưu vào (loại bộ hệ thống — backend chặn ghi vào owner=NULL).
  Future<List<VocabDeck>> loadSavableDecks() async {
    final decks = await _deckRepo.getDecks();
    return decks.where((d) => !d.isSystem).toList();
  }

  /// Tạo nhanh 1 bộ thẻ theo CEFR (cho user chưa có bộ nào).
  Future<VocabDeck> createDeckForLevel(String cefr) {
    return _deckRepo.createDeck(cefrLevel: cefr);
  }

  /// Lưu từ vựng hằng ngày vào bộ thẻ đã chọn. Map WordOfDayDto → CreateFlashcardRequest.
  /// Trả true nếu lưu mới thành công; ném lại lỗi khác 409 để UI báo.
  Future<bool> saveWordToDeck(VocabDeck deck) async {
    final w = wordOfDay;
    if (w == null) return false;
    final pos = (w.partOfSpeech != null && w.partOfSpeech!.trim().isNotEmpty)
        ? [w.partOfSpeech!.trim()]
        : <String>[];
    try {
      await _deckRepo.createFlashcard(
        deckId: deck.id,
        word: w.word,
        ipa: w.pronunciation ?? '',
        pos: pos,
        vietnamese: w.definitionVi ?? '',
        example: w.exampleSentence ?? '',
        cefr: (w.level != null && w.level!.trim().isNotEmpty)
            ? w.level!.trim().toUpperCase()
            : deck.cefrLevel,
      );
      wordSaved.value = true;
      return true;
    } on DioException catch (e) {
      // 409 = từ đã có trong bộ này → coi như đã lưu, không phải lỗi thật.
      if (e.response?.statusCode == 409) {
        wordSaved.value = true;
        return false;
      }
      rethrow;
    }
  }

  // "Xem lộ trình" → chuyển sang tab Học (index 1) trong shell, giữ bottom navbar.
  void onSeeAllLessons() => ShellController.goToTab(1);

  void onStartPlacementTest() => Get.toNamed(AppRoutes.placementTest);

  void onContinueLearning() {
    Get.toNamed(
      AppRoutes.curriculumUnits,
      arguments: {'level': homeLevel},
    );
  }

  /// Mở thẳng Unit đang học từ Home, refresh lại khi quay về.
  Future<void> openUnitFromHome(CurriculumUnit unit) async {
    if (unit.isLocked) return;
    await Get.toNamed(
      AppRoutes.curriculumUnitDetail,
      arguments: {'unitId': unit.id},
    );
    loadCurrentUnit();
  }

  /// Điều hướng nhanh từ dải nút truy cập nhanh ở Home.
  void openQuickAction(String key) {
    switch (key) {
      case 'vocabulary':
        Get.toNamed(AppRoutes.vocabHub);
      case 'grammar':
        Get.toNamed(AppRoutes.grammarTheory);
      case 'flashcard':
        Get.toNamed(AppRoutes.flashcards);
      case 'pronunciation':
        Get.toNamed(AppRoutes.pronunciation);
      case 'test':
        Get.toNamed(AppRoutes.test);
    }
  }

  void onRecommendTap(HomeRecommendation item) {
    switch (item.type) {
      case 'vocabulary':
        Get.toNamed(AppRoutes.vocabHub);
      case 'grammar':
        Get.toNamed(AppRoutes.grammarTheory);
      case 'exercise':
        Get.toNamed(AppRoutes.learningSupport);
      case 'pronunciation':
        Get.toNamed(AppRoutes.pronunciation);
      case 'flashcard':
        Get.toNamed(AppRoutes.flashcards);
      case 'test':
        Get.toNamed(AppRoutes.learningSupport);
    }
  }
}
