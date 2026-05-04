import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/data/models/desk_model.dart';
import 'package:englishme/data/repositories/flashcard_repository.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class CreateDeskController extends GetxController {
  CreateDeskController({this.editingDesk});

  /// Khi khác `null` — chế độ sửa bộ thẻ (API `PUT /desks/{id}`).
  final DeskModel? editingDesk;

  bool get isEditMode => editingDesk != null;

  final formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  late final FlashcardRepository _repo;

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
    _repo = FlashcardRepository(DioClient.instance);
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
    if (Get.isRegistered<FlashcardController>()) {
      await Get.find<FlashcardController>().loadDesks();
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
        isEditMode ? 'Không cập nhật được bộ thẻ' : 'Không tạo được bộ thẻ',
        msg ?? e.message ?? 'Lỗi mạng',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> confirmAndDeleteDesk() async {
    if (!isEditMode || isSubmitting.value) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa bộ thẻ?'),
        content: Text('Bạn có chắc muốn xóa bộ "${editingDesk!.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Xóa',
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
      Get.snackbar('Đã xóa', editingDesk!.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      Get.snackbar('Không xóa được', msg ?? e.message ?? 'Lỗi mạng');
    } finally {
      isSubmitting.value = false;
    }
  }
}
