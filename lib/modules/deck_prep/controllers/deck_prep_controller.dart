import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_deck_controller.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/modules/study_session/models/due_cards_response.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/modules/study_session/views/study_session_front_screen.dart';
import 'package:englishme/routes/app_routes.dart';

class DeckPrepController extends GetxController {
  DeckPrepController({
    required this.deck,
    required VocabDeckRepository repo,
    required StudySessionRepository sessionRepo,
  })  : _repo = repo,
        _sessionRepo = sessionRepo;

  final VocabDeck deck;

  /// Bộ hệ thống (owner=NULL ở backend): user chỉ được học, không sửa/xoá/thêm thẻ.
  /// Backend cũng chặn (trả 404 theo owner) — đây là lớp ẩn UI cho khớp.
  bool get isSystem => deck.isSystem;

  final VocabDeckRepository _repo;
  final StudySessionRepository _sessionRepo;

  final RxList<VocabWord> previewCards = <VocabWord>[].obs;
  final Rxn<DueCardsResponse> dueCards = Rxn();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  /// Số thẻ thêm trong phiên này (deck từ API chưa cập nhật `flashcardCount`).
  final RxInt addedSinceOpen = 0.obs;

  int get cardCount => deck.flashcardCount + addedSinceOpen.value;

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
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final page = await _repo.getFlashcards(deck.id, size: 30);
      previewCards.value = page.content;
      // Due cards là phụ — không fail toàn flow nếu lỗi.
      try {
        dueCards.value = await _sessionRepo.getDueCards(deck.id);
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
    unawaited(tts.speak(word));
  }

  void startStudySession() {
    if (previewCards.isEmpty) {
      AppNotify.warning(
        T.errorEmptyDeckForStudy.tr,
        message: T.deckEmptyForStudy.tr,
      );
      return;
    }
    if (Get.isRegistered<StudySessionController>()) {
      Get.delete<StudySessionController>();
    }
    Get.put<StudySessionController>(
      StudySessionController(
        deskId: deck.id,
        deskTitle: deck.title,
        repo: _sessionRepo,
      ),
      permanent: true,
    );
    Get.off(() => const StudySessionFrontScreen());
  }

  Future<void> onAddCard() async {
    final created = await Get.toNamed<dynamic>(
      AppRoutes.addFlashcard,
      arguments: deck,
    );
    if (created == true) {
      addedSinceOpen.value++;
      await _loadPreview();
      if (Get.isRegistered<VocabDeckController>()) {
        unawaited(Get.find<VocabDeckController>().loadDecks());
      }
    }
  }

  void openEditDeck() {
    Get.toNamed(AppRoutes.createDeck, arguments: deck);
  }

  Future<void> confirmDeleteThisDeck() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.errorDeleteDeckTitle.tr),
        content: Text(T.errorDeleteDeckContent.trParams({'title': deck.title})),
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
      if (Get.isRegistered<VocabDeckController>()) {
        await Get.find<VocabDeckController>().loadDecks();
      }
      Get.until(
        (route) => route.settings.name == AppRoutes.flashcards || route.isFirst,
      );
      AppNotify.success(T.deckDeleted.tr, message: deck.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      AppNotify.error(
        T.errorDeleteFailedTitle.tr,
        message: msg ?? e.message ?? T.errorNetwork.tr,
      );
    }
  }

  Future<void> onEditCard(VocabWord card) async {
    final updated = await Get.toNamed<dynamic>(
      AppRoutes.addFlashcard,
      arguments: AddFlashcardArgs(deck: deck, editCard: card),
    );
    if (updated == true) {
      await _loadPreview();
      if (Get.isRegistered<VocabDeckController>()) {
        unawaited(Get.find<VocabDeckController>().loadDecks());
      }
    }
  }
}
