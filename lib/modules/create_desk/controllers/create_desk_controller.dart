import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_desk_repository.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_desk_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class CreateDeskController extends GetxController {
  CreateDeskController({this.editingDesk});

  /// Khi khác `null` — chế độ sửa bộ thẻ (API `PUT /desks/{id}`).
  final VocabDesk? editingDesk;

  bool get isEditMode => editingDesk != null;

  final formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  late final VocabDeskRepository _repo;

  final RxBool isSubmitting = false.obs;
  final RxString selectedCefr = 'A1'.obs;
  final RxString selectedColor = '#24389C'.obs;
  final RxString selectedIcon = 'book'.obs;

  static const List<String> cefrOptions = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const List<String> colorOptions = [
    '#24389C',
    '#E67E22',
    '#565C84',
    '#E53935',
    '#818CF8',
    '#334155',
  ];

  static const List<String> iconOptions = [
    'book',
    'edit',
    'mic',
    'chat_bubble',
    'translate',
    'school',
  ];

  @override
  void onInit() {
    super.onInit();
    _repo = VocabDeskRepository(DioClient.instance);
    _applyEditingDeskIfAny();
  }

  void _applyEditingDeskIfAny() {
    final d = editingDesk;
    if (d == null) return;
    titleCtrl.text = d.title;
    final lvl = d.cefrLevel.toUpperCase();
    selectedCefr.value = cefrOptions.contains(lvl) ? lvl : 'A1';
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> _reloadFlashcardListIfAny() async {
    if (Get.isRegistered<VocabDeskController>()) {
      await Get.find<VocabDeskController>().loadDesks();
    }
  }

  Future<void> submitDesk() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    try {
      if (isEditMode) {
        final desk = await _repo.updateDesk(
          deskId: editingDesk!.id,
          title: titleCtrl.text.trim(),
          cefrLevel: selectedCefr.value,
        );
        await _reloadFlashcardListIfAny();
        Get.offNamed(AppRoutes.deckPrep, arguments: desk);
      } else {
        final desk = await _repo.createDesk(
          title: titleCtrl.text.trim(),
          cefrLevel: selectedCefr.value,
        );
        await _reloadFlashcardListIfAny();
        Get.offNamed(AppRoutes.deckPrep, arguments: desk);
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      Get.snackbar(
        isEditMode ? T.errorUpdateDeskFailed.tr : T.errorCreateDeskFailed.tr,
        msg ?? e.message ?? T.errorNetwork.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> confirmAndDeleteDesk() async {
    if (!isEditMode || isSubmitting.value) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.errorDeleteDeskTitle.tr),
        content: Text(T.errorDeleteDeskContent.trParams({'title': editingDesk!.title})),
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
    isSubmitting.value = true;
    try {
      await _repo.deleteDesk(editingDesk!.id);
      await _reloadFlashcardListIfAny();
      Get.until((route) => route.settings.name == AppRoutes.flashcards || route.isFirst);
      Get.snackbar(T.deckDeleted.tr, editingDesk!.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      Get.snackbar(T.errorDeleteFailedTitle.tr, msg ?? e.message ?? T.errorNetwork.tr);
    } finally {
      isSubmitting.value = false;
    }
  }
}
