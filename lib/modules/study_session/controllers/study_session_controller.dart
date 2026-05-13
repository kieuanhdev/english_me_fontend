import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/data/models/flashcard_model.dart';
import 'package:englishme/data/repositories/flashcard_repository.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_back_screen.dart';
import 'package:englishme/routes/app_routes.dart';

enum CardRating { forget, vague, remember, mastered }

class StudySessionController extends GetxController {
  final String deskId;
  final String deskTitle;

  StudySessionController({required this.deskId, required this.deskTitle});

  late final FlashcardRepository _repo;

  // Loading state
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Cards
  final RxList<FlashcardModel> cards = <FlashcardModel>[].obs;
  final RxInt currentIndex = 0.obs;

  // Rating counts
  final RxInt masteredCount = 0.obs;
  final RxInt rememberCount = 0.obs;
  final RxInt vagueCount = 0.obs;
  final RxInt forgetCount = 0.obs;

  // Summary stats (mock — sẽ lấy từ user profile sau)
  final RxInt streakDays = 7.obs;
  final RxInt xpEarned = 25.obs;
  final RxInt currentLevel = 12.obs;
  final RxDouble xpProgress = 0.75.obs;

  FlashcardModel get currentCard => cards[currentIndex.value];
  int get totalCards => cards.length;
  int get totalReviewed =>
      masteredCount.value + rememberCount.value + vagueCount.value + forgetCount.value;

  @override
  void onInit() {
    super.onInit();
    _repo = FlashcardRepository(DioClient.instance);
    _loadCards();
  }

  Future<void> retryLoad() => _loadCards();

  Future<void> _loadCards() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final page = await _repo.getFlashcards(deskId, page: 0, size: 40);
      cards.value = page.content;
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Lỗi kết nối';
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

  void flipCard() => Get.to(() => const StudySessionBackScreen(), preventDuplicates: false);

  void rateCard(CardRating rating) {
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
      Get.back();
    } else {
      Get.off(() => const SessionSummaryScreen());
    }
  }

  void closeSession() {
    Get.until(
      (route) => route.settings.name == AppRoutes.flashcards || route.isFirst,
    );
    Get.delete<StudySessionController>();
  }
}
