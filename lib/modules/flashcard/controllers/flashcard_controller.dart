import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/data/models/desk_model.dart';
import 'package:englishme/data/repositories/flashcard_repository.dart';
import 'package:englishme/routes/app_routes.dart';

class FlashcardController extends GetxController {
  late final FlashcardRepository _repo;

  final RxList<DeskModel> desks = <DeskModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Stats (mock — sẽ lấy từ user profile sau)
  final RxInt dayStreak = 12.obs;
  final RxInt avgMastery = 85.obs;

  // Word of the day (mock)
  final RxString wordOfDay = 'Eloquent'.obs;
  final RxString wordDefinition = 'Fluent or persuasive in speaking or writing.'.obs;

  @override
  void onInit() {
    super.onInit();
    _repo = FlashcardRepository(DioClient.instance);
    loadDesks();
  }

  Future<void> loadDesks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      desks.value = await _repo.getDesks();
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Lỗi kết nối';
    } finally {
      isLoading.value = false;
    }
  }

  void onStartStudy(DeskModel desk) {
    Get.toNamed(AppRoutes.deckPrep, arguments: desk);
  }

  void onPracticeWordOfDay() {}

  void onCreateDeck() {
    Get.toNamed(AppRoutes.createDesk);
  }

  void onViewAll() {}
}
