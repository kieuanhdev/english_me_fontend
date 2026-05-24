import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_desk_repository.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_desk_controller.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/modules/study_session/models/due_cards_response.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/modules/study_session/views/study_session_front_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class DeckPrepController extends GetxController {
  DeckPrepController({required this.desk});

  final VocabDesk desk;

  late final VocabDeskRepository _repo;
  late final StudySessionRepository _sessionRepo;

  final RxList<VocabWord> previewCards = <VocabWord>[].obs;
  final Rxn<DueCardsResponse> dueCards = Rxn();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  /// Số thẻ thêm trong phiên này (desk từ API chưa cập nhật `flashcardCount`).
  final RxInt addedSinceOpen = 0.obs;

  int get cardCount => desk.flashcardCount + addedSinceOpen.value;

  /// Số thẻ đã đến hạn ôn (SM-2 nextReviewAt <= now) — lấy từ backend.
  int get dueCardsCount => dueCards.value?.totalDue ?? 0;

  /// Số thẻ mới chưa từng ôn — lấy từ backend.
  int get newCardsCount => dueCards.value?.totalNew ?? 0;

  int get masteredCardsCount =>
      (cardCount - dueCardsCount - newCardsCount).clamp(0, cardCount);

  int get weeklyMasteryPercent {
    final n = cardCount;
    if (n <= 0) return 0;
    return ((masteredCardsCount / n) * 100).round();
  }

  @override
  void onInit() {
    super.onInit();
    _repo = VocabDeskRepository(DioClient.instance);
    _sessionRepo = StudySessionRepository(DioClient.instance);
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final page = await _repo.getFlashcards(desk.id, page: 0, size: 30);
      previewCards.value = page.content;
      // Due cards là phụ — không fail toàn flow nếu lỗi.
      try {
        dueCards.value = await _sessionRepo.getDueCards(desk.id);
      } catch (_) {
        dueCards.value = null;
      }
    } on DioException catch (e) {
      errorMessage.value = e.message ?? T.errorConnection.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryLoad() => _loadPreview();

  void speakWord(String word) {
    final tts = Get.find<TtsService>();
    tts.speak(word);
  }

  void startStudySession() {
    if (previewCards.isEmpty) {
      Get.snackbar(T.errorEmptyDeckForStudy.tr, T.deckEmptyForStudy.tr);
      return;
    }
    if (Get.isRegistered<StudySessionController>()) {
      Get.delete<StudySessionController>();
    }
    Get.put<StudySessionController>(
      StudySessionController(deskId: desk.id, deskTitle: desk.title),
      permanent: true,
    );
    Get.off(() => const StudySessionFrontScreen());
  }

  Future<void> onAddCard() async {
    final created = await Get.toNamed<dynamic>(AppRoutes.addFlashcard, arguments: desk);
    if (created == true) {
      addedSinceOpen.value++;
      await _loadPreview();
      if (Get.isRegistered<VocabDeskController>()) {
        Get.find<VocabDeskController>().loadDesks();
      }
    }
  }

  void openEditDesk() {
    Get.toNamed(AppRoutes.createDesk, arguments: desk);
  }

  Future<void> confirmDeleteThisDesk() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.errorDeleteDeskTitle.tr),
        content: Text(T.errorDeleteDeskContent.trParams({'title': desk.title})),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(T.actionCancel.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              T.actionDelete.tr,
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.deleteDesk(desk.id);
      if (Get.isRegistered<VocabDeskController>()) {
        await Get.find<VocabDeskController>().loadDesks();
      }
      Get.until((route) => route.settings.name == AppRoutes.flashcards || route.isFirst);
      Get.snackbar(T.deckDeleted.tr, desk.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? (e.response!.data as Map)['message']?.toString() : null;
      Get.snackbar(T.errorDeleteFailedTitle.tr, msg ?? e.message ?? T.errorNetwork.tr);
    }
  }

  Future<void> onEditCard(VocabWord card) async {
    final updated = await Get.toNamed<dynamic>(
      AppRoutes.addFlashcard,
      arguments: AddFlashcardArgs(desk: desk, editCard: card),
    );
    if (updated == true) {
      await _loadPreview();
      if (Get.isRegistered<VocabDeskController>()) {
        Get.find<VocabDeskController>().loadDesks();
      }
    }
  }
}
