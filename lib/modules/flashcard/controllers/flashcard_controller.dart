import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/flashcard/models/desk_model.dart';
import 'package:englishme/modules/flashcard/repositories/flashcard_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

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
      errorMessage.value = e.message ?? T.errorConnection.tr;
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

  void onEditDeck(DeskModel desk) {
    Get.toNamed(AppRoutes.createDesk, arguments: desk);
  }

  Future<void> onDeleteDeck(DeskModel desk) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.errorDeleteDeskTitle.tr),
        content: Text(T.errorDeleteDeskContentSimple.trParams({'title': desk.title})),
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
      await loadDesks();
      Get.snackbar(T.deckDeleted.tr, desk.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? (e.response!.data as Map)['message']?.toString() : null;
      Get.snackbar(T.errorDeleteFailedTitle.tr, msg ?? e.message ?? T.errorNetwork.tr);
    }
  }

  void onViewAll() {}
}
