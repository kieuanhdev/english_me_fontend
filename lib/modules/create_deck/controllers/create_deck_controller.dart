import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_deck_controller.dart';
import 'package:englishme/routes/app_routes.dart';

class CreateDeckController extends GetxController {
  CreateDeckController({
    required VocabDeckRepository repo,
    this.editingDeck,
  }) : _repo = repo;

  /// Khi khác `null` — chế độ sửa bộ thẻ (API `PUT /desks/{id}`).
  final VocabDeck? editingDeck;

  bool get isEditMode => editingDeck != null;

  final formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final VocabDeckRepository _repo;

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
    _applyEditingDeckIfAny();
  }

  void _applyEditingDeckIfAny() {
    final d = editingDeck;
    if (d == null) return;
    titleCtrl.text = d.title;
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> _reloadFlashcardListIfAny() async {
    if (Get.isRegistered<VocabDeckController>()) {
      await Get.find<VocabDeckController>().loadDecks();
    }
  }

  Future<void> submitDeck() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    try {
      if (isEditMode) {
        final deck = await _repo.updateDeck(
          deckId: editingDeck!.id,
          title: titleCtrl.text.trim(),
        );
        await _reloadFlashcardListIfAny();
        Get.offNamed(AppRoutes.deckPrep, arguments: deck);
      } else {
        final deck = await _repo.createDeck(title: titleCtrl.text.trim());
        await _reloadFlashcardListIfAny();
        Get.offNamed(AppRoutes.deckPrep, arguments: deck);
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      AppNotify.error(
        isEditMode ? T.errorUpdateDeckFailed.tr : T.errorCreateDeckFailed.tr,
        message: msg ?? e.message ?? T.errorNetwork.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> confirmAndDeleteDeck() async {
    if (!isEditMode || isSubmitting.value) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.errorDeleteDeckTitle.tr),
        content: Text(
          T.errorDeleteDeckContent.trParams({'title': editingDeck!.title}),
        ),
        actions: [
          AppButton(
            label: T.actionCancel,
            onPressed: () => Get.back(result: false),
            variant: AppButtonVariant.text,
            expand: false,
            height: 44,
          ),
          AppButton(
            label: T.actionDelete,
            onPressed: () => Get.back(result: true),
            variant: AppButtonVariant.dangerText,
            expand: false,
            height: 44,
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    isSubmitting.value = true;
    try {
      await _repo.deleteDeck(editingDeck!.id);
      await _reloadFlashcardListIfAny();
      Get.until(
        (route) => route.settings.name == AppRoutes.flashcards || route.isFirst,
      );
      AppNotify.success(T.deckDeleted.tr, message: editingDeck!.title);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      AppNotify.error(
        T.errorDeleteFailedTitle.tr,
        message: msg ?? e.message ?? T.errorNetwork.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
