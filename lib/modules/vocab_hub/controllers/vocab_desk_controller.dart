import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_desk_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabDeskController extends GetxController {
  late final VocabDeskRepository _repo;

  final desks = <VocabDesk>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // Stats (mock — sẽ lấy từ user profile sau)
  final dayStreak = 12.obs;
  final avgMastery = 85.obs;

  // Word of the day (mock)
  final wordOfDay = 'Eloquent'.obs;
  final wordDefinition = 'Fluent or persuasive in speaking or writing.'.obs;

  @override
  void onInit() {
    super.onInit();
    _repo = VocabDeskRepository(Get.find());
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

  void onStartStudy(VocabDesk desk) => Get.toNamed(AppRoutes.deckPrep, arguments: desk);

  void onPracticeWordOfDay() {}

  void onCreateDeck() => Get.toNamed(AppRoutes.createDesk);

  void onEditDeck(VocabDesk desk) => Get.toNamed(AppRoutes.createDesk, arguments: desk);

  Future<void> onDeleteDeck(VocabDesk desk) async {
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
