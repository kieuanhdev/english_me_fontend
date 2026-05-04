import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/data/models/desk_model.dart';
import 'package:englishme/data/models/flashcard_model.dart';
import 'package:englishme/data/repositories/flashcard_repository.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/modules/study_session/views/study_session_front_screen.dart';
import 'package:englishme/routes/app_routes.dart';

class DeckPrepController extends GetxController {
  DeckPrepController({required this.desk});

  final DeskModel desk;

  late final FlashcardRepository _repo;

  final RxList<FlashcardModel> previewCards = <FlashcardModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  /// Số thẻ thêm trong phiên này (desk từ API chưa cập nhật `flashcardCount`).
  final RxInt addedSinceOpen = 0.obs;

  int get cardCount => desk.flashcardCount + addedSinceOpen.value;

  /// Tiến độ tuần (mock — đồng bộ số thẻ với bộ; API thống kê sau sẽ thay).
  int get weeklyMasteryPercent {
    final n = cardCount;
    if (n <= 0) return 0;
    final mastered = (n * 0.67).round().clamp(0, n);
    return ((mastered / n) * 100).round();
  }

  int get newCardsCount {
    final n = cardCount;
    if (n <= 0) return 0;
    return (n * 0.29).round().clamp(0, n);
  }

  int get masteredCardsCount => (cardCount - newCardsCount).clamp(0, cardCount);

  @override
  void onInit() {
    super.onInit();
    _repo = FlashcardRepository(DioClient.instance);
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final page = await _repo.getFlashcards(desk.id, page: 0, size: 30);
      previewCards.value = page.content;
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Lỗi kết nối';
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
      Get.snackbar('Bộ thẻ trống', 'Chưa có thẻ để học.');
      return;
    }
    if (Get.isRegistered<StudySessionController>()) {
      Get.delete<StudySessionController>();
    }
    Get.put<StudySessionController>(
      StudySessionController(deskId: desk.id, deskTitle: desk.title),
    );
    Get.off(() => const StudySessionFrontScreen());
  }

  Future<void> onAddCard() async {
    final created = await Get.toNamed<dynamic>(AppRoutes.addFlashcard, arguments: desk);
    if (created == true) {
      addedSinceOpen.value++;
      await _loadPreview();
      if (Get.isRegistered<FlashcardController>()) {
        Get.find<FlashcardController>().loadDesks();
      }
    }
  }

  Future<void> onEditCard(FlashcardModel card) async {
    final updated = await Get.toNamed<dynamic>(
      AppRoutes.addFlashcard,
      arguments: AddFlashcardArgs(desk: desk, editCard: card),
    );
    if (updated == true) {
      await _loadPreview();
      if (Get.isRegistered<FlashcardController>()) {
        Get.find<FlashcardController>().loadDesks();
      }
    }
  }
}
