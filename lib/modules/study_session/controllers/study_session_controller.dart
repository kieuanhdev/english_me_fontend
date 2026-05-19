import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/flashcard/models/flashcard_model.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/study_session/models/review_response.dart';
import 'package:englishme/modules/study_session/models/study_session_summary.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_back_screen.dart';
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

  StudySessionController({required this.deskId, required this.deskTitle});

  late final StudySessionRepository _repo;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxList<FlashcardModel> cards = <FlashcardModel>[].obs;
  final RxInt currentIndex = 0.obs;

  // Đếm cục bộ (UI hiển thị live trong khi chờ summary).
  final RxInt masteredCount = 0.obs;
  final RxInt rememberCount = 0.obs;
  final RxInt vagueCount = 0.obs;
  final RxInt forgetCount = 0.obs;

  // XP tích luỹ — backend trả qua ReviewResponse.sessionXp.
  final RxInt sessionXp = 0.obs;

  // Summary lấy từ backend khi hết session.
  final Rxn<StudySessionSummary> summary = Rxn();

  String _sessionId = '';
  DateTime _cardStartedAt = DateTime.now();

  FlashcardModel get currentCard => cards[currentIndex.value];
  int get totalCards => cards.length;
  int get totalReviewed =>
      masteredCount.value + rememberCount.value + vagueCount.value + forgetCount.value;

  @override
  void onInit() {
    super.onInit();
    _repo = StudySessionRepository(DioClient.instance);
    _startSession();
  }

  Future<void> retryLoad() => _startSession();

  Future<void> _startSession() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final session = await _repo.startSession(deskId, limit: 20);
      _sessionId = session.sessionId;
      cards.value = session.cards;
      currentIndex.value = 0;
      masteredCount.value = 0;
      rememberCount.value = 0;
      vagueCount.value = 0;
      forgetCount.value = 0;
      sessionXp.value = 0;
      summary.value = null;
      _cardStartedAt = DateTime.now();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void speak() {
    if (cards.isEmpty) return;
    final card = currentCard;
    final tts = Get.find<TtsService>();
    tts.speak(card.word);
  }

  void flipCard() => Get.to(
    () => const StudySessionBackScreen(),
    preventDuplicates: false,
  );

  Future<void> rateCard(CardRating rating) async {
    if (cards.isEmpty || _sessionId.isEmpty) return;
    final card = currentCard;

    // Cộng đếm cục bộ ngay để UI mượt.
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

    final responseTimeMs =
        DateTime.now().difference(_cardStartedAt).inMilliseconds;
    try {
      final res = await _repo.reviewCard(
        _sessionId,
        ReviewRequest(
          flashcardId: card.id,
          quality: _qualityFromRating(rating),
          responseTimeMs: responseTimeMs,
        ),
      );
      sessionXp.value = res.sessionXp;
    } catch (_) {
      Get.snackbar(
        T.errorGeneric.tr,
        T.errorSyncCard.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (currentIndex.value < cards.length - 1) {
      currentIndex.value++;
      _cardStartedAt = DateTime.now();
      Get.back();
    } else {
      await _loadSummary();
      Get.off(() => const SessionSummaryScreen());
    }
  }

  Future<void> _loadSummary() async {
    if (_sessionId.isEmpty) return;
    try {
      summary.value = await _repo.getSummary(_sessionId);
    } catch (_) {
      // ignore — UI dùng đếm cục bộ làm fallback.
    }
  }

  void closeSession() {
    // Refresh Profile + Progress để XP/streak mới hiển thị ngay khi user chuyển tab.
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }
    if (Get.isRegistered<ProgressController>()) {
      Get.find<ProgressController>().loadProgress();
    }
    Get.until(
      (route) => route.settings.name == AppRoutes.flashcards || route.isFirst,
    );
    Get.delete<StudySessionController>();
  }
}
