import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';

import 'package:englishme/core/network/api_exception.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/study_session/models/review_response.dart';
import 'package:englishme/modules/study_session/models/study_session_summary.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/routes/app_routes.dart';

enum CardRating { forget, vague, remember, mastered }

/// Map UI rating → SM-2 quality (0..5).
/// forget=1 / vague=2 / remember=4 / mastered=5. q<3 = lapse, reset repetitions.
int _qualityFromRating(CardRating rating) {
  switch (rating) {
    case CardRating.forget:
      return 1;
    case CardRating.vague:
      return 2;
    case CardRating.remember:
      return 4;
    case CardRating.mastered:
      return 5;
  }
}

class StudySessionController extends GetxController {
  final String deskId;
  final String deskTitle;
  final StudySessionRepository _repo;

  StudySessionController({
    required this.deskId,
    required this.deskTitle,
    required StudySessionRepository repo,
  }) : _repo = repo;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxList<VocabWord> cards = <VocabWord>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isCardFlipped = false.obs;
  final RxBool isReviewing = false.obs;

  // Đếm cục bộ (UI hiển thị live trong khi chờ summary).
  final RxInt masteredCount = 0.obs;
  final RxInt rememberCount = 0.obs;
  final RxInt vagueCount = 0.obs;
  final RxInt forgetCount = 0.obs;

  // XP tích luỹ — backend trả qua ReviewResponse.sessionXp.
  final RxInt sessionXp = 0.obs;

  // SM-2 interval của thẻ vừa đánh giá — hiển thị chip "Ôn lại sau X ngày".
  final RxInt lastIntervalDays = 0.obs;
  final Rxn<DateTime> lastNextReviewAt = Rxn<DateTime>();

  // Summary lấy từ backend khi hết session.
  final Rxn<StudySessionSummary> summary = Rxn();

  String _sessionId = '';
  DateTime _cardStartedAt = DateTime.now();

  VocabWord get currentCard => cards[currentIndex.value];
  int get totalCards => cards.length;
  int get totalReviewed =>
      masteredCount.value +
      rememberCount.value +
      vagueCount.value +
      forgetCount.value;

  @override
  void onInit() {
    super.onInit();
    _startSession();
  }

  @override
  void onClose() {
    // XP chỉ cộng khi hoàn thành phiên, và đã được apply (kèm refresh Home/Progress)
    // trong _loadSummary. Thoát giữa chừng → không cộng XP → không cần refresh.
    super.onClose();
  }

  Future<void> retryLoad() => _startSession();

  Future<void> _startSession() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final session = await _repo.startSession(deskId);
      _sessionId = session.sessionId;
      cards.value = session.cards;
      currentIndex.value = 0;
      isCardFlipped.value = false;
      isReviewing.value = false;
      masteredCount.value = 0;
      rememberCount.value = 0;
      vagueCount.value = 0;
      forgetCount.value = 0;
      sessionXp.value = 0;
      summary.value = null;
      _cardStartedAt = DateTime.now();
      _autoSpeakCurrent();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void speak() {
    if (cards.isEmpty) return;
    final tts = Get.find<TtsService>();
    tts.speak(currentCard.word);
  }

  /// Tự phát âm từ của thẻ hiện tại nếu user bật auto-speak (TtsService.autoSpeak).
  /// Gọi khi mở thẻ mới: lúc bắt đầu phiên và khi chuyển sang thẻ kế.
  void _autoSpeakCurrent() {
    if (cards.isEmpty) return;
    final tts = Get.find<TtsService>();
    if (!tts.autoSpeak.value) return;
    tts.speak(currentCard.word);
  }

  void flipCard() => isCardFlipped.toggle();

  Future<void> rateCard(CardRating rating) async {
    if (cards.isEmpty || _sessionId.isEmpty || isReviewing.value) return;
    final card = currentCard;
    if (card.id.trim().isEmpty) {
      AppNotify.error(T.errorGeneric.tr, message: 'Thiếu flashcardId cho thẻ "${card.word}". Vui lòng tải lại phiên học.');
      return;
    }

    final responseTimeMs = DateTime.now()
        .difference(_cardStartedAt)
        .inMilliseconds;
    try {
      isReviewing.value = true;
      final res = await _repo.reviewCard(
        _sessionId,
        ReviewRequest(
          flashcardId: card.id,
          quality: _qualityFromRating(rating),
          responseTimeMs: responseTimeMs,
        ),
      );
      // XP chỉ cộng khi HOÀN THÀNH cả phiên (BE grant ở /summary). Ở mỗi thẻ
      // chỉ cập nhật `sessionXp` (pending) để hiển thị live; KHÔNG apply XP/streak
      // per-thẻ. Việc apply 1 lần (cộng total, streak, bonus, sound) nằm ở _loadSummary.
      sessionXp.value = res.sessionXp;
      lastIntervalDays.value = res.intervalDays;
      lastNextReviewAt.value = res.nextReviewAt;

      switch (rating) {
        case CardRating.mastered:
          masteredCount.value++;
        case CardRating.remember:
          rememberCount.value++;
        case CardRating.vague:
          vagueCount.value++;
        case CardRating.forget:
          forgetCount.value++;
      }

      if (currentIndex.value < cards.length - 1) {
        currentIndex.value++;
        isCardFlipped.value = false;
        _cardStartedAt = DateTime.now();
        _autoSpeakCurrent();
      } else {
        await _loadSummary();
        Get.off(() => const SessionSummaryScreen());
      }
    } on DioException catch (e) {
      AppNotify.error(T.errorGeneric.tr, message: _reviewErrorMessage(e));
    } catch (e) {
      AppNotify.error(T.errorGeneric.tr, message: e.toString());
    } finally {
      isReviewing.value = false;
    }
  }

  String _reviewErrorMessage(DioException e) {
    final error = e.error;
    if (error is ApiException && error.message.isNotEmpty) {
      return error.message;
    }
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? T.errorSyncCard.tr;
  }

  Future<void> _loadSummary() async {
    if (_sessionId.isEmpty) return;
    try {
      final s = await _repo.getSummary(_sessionId);
      summary.value = s;
      // BE grant XP 1 lần khi phiên hoàn thành → summary trả totalXp (non-null).
      // Apply tại đây: cộng total + streak + bonus + phát sound/confetti 1 lần.
      final total = s.totalXp;
      if (total != null) {
        XpGrantHandler.apply(
          totalXp: total,
          xpEarned: s.xpEarned,
          streakUpdated: s.streakUpdated,
          bonuses: s.bonuses,
        );
      }
    } catch (e) {
      // UI dùng đếm cục bộ làm fallback — không chặn flow, chỉ log để debug.
      if (kDebugMode) debugPrint('[StudySession] _loadSummary failed: $e');
    }
  }

  void closeSession() {
    // XP/streak đã được update inline qua XpGrantHandler trong rateCard,
    // không cần refetch Profile/Progress khi đóng session.
    Get.until(
      (route) => route.settings.name == AppRoutes.flashcards || route.isFirst,
    );
    Get.delete<StudySessionController>();
  }
}
