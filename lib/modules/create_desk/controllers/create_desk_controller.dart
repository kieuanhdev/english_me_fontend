import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/data/repositories/flashcard_repository.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/routes/app_routes.dart';

class CreateDeskController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  late final FlashcardRepository _repo;

  final RxBool isSubmitting = false.obs;
  final RxString selectedColor = '#24389C'.obs;
  final RxString selectedIcon = 'book'.obs;

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
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> createDesk() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    try {
      final desk = await _repo.createDesk(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        color: selectedColor.value,
        icon: selectedIcon.value,
      );
      if (Get.isRegistered<FlashcardController>()) {
        await Get.find<FlashcardController>().loadDesks();
      }
      Get.offNamed(AppRoutes.deckPrep, arguments: desk);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      Get.snackbar('Không tạo được bộ thẻ', msg ?? e.message ?? 'Lỗi mạng');
    } finally {
      isSubmitting.value = false;
    }
  }
}
