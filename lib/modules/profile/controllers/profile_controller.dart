import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/profile/models/profile_model.dart';
import 'package:englishme/modules/profile/repositories/profile_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/theme_controller.dart';

enum ProfileLoadState { idle, loading, success, error }

class ProfileController extends GetxController {
  final ProfileRepository _repo;

  ProfileController(this._repo);

  final loadState = ProfileLoadState.idle.obs;
  final Rxn<ProfileUser> user = Rxn<ProfileUser>();
  final isEditingName = false.obs;
  final isSavingName = false.obs;
  final nameController = TextEditingController();

  ThemeController get _themeCtrl => Get.find<ThemeController>();
  ThemeMode get themeMode => _themeCtrl.themeMode;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    try {
      loadState.value = ProfileLoadState.loading;
      final result = await _repo.getProfile();
      user.value = result;
      nameController.text = result.displayName;
      loadState.value = ProfileLoadState.success;
    } catch (_) {
      loadState.value = ProfileLoadState.error;
    }
  }

  void startEditName() {
    nameController.text = user.value?.displayName ?? '';
    isEditingName.value = true;
  }

  void cancelEditName() {
    isEditingName.value = false;
  }

  Future<void> saveDisplayName() async {
    final name = nameController.text.trim();
    if (name.isEmpty || name == user.value?.displayName) {
      isEditingName.value = false;
      return;
    }
    try {
      isSavingName.value = true;
      user.value = await _repo.updateDisplayName(name);
      isEditingName.value = false;
    } catch (_) {
      Get.snackbar(T.errorGeneric.tr, T.errorUpdateName.tr);
    } finally {
      isSavingName.value = false;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _themeCtrl.setThemeMode(mode);
  }

  Future<void> signOut() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(T.actionLogout.tr),
        content: Text(T.profileLogoutConfirmContent.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(T.actionCancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(T.actionLogout.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  void goToPlacementTest() {
    Get.toNamed(AppRoutes.placementTest);
  }

  String get cefrLabel {
    const map = {
      'A1': 'Beginner',
      'A2': 'Elementary',
      'B1': 'Intermediate',
      'B2': 'Upper Intermediate',
      'C1': 'Advanced',
      'C2': 'Proficient',
    };
    return map[user.value?.cefrLevel] ?? '';
  }

}
