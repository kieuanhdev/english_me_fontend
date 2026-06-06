import 'package:englishme/core/utils/app_notify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/profile/models/profile_model.dart';
import 'package:englishme/modules/profile/repositories/profile_repository.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/models/daily_goal.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/theme_controller.dart';

enum ProfileLoadState { idle, loading, success, error }

class ProfileController extends GetxController {
  final ProfileRepository _repo;
  final ProgressRepository _progressRepo;

  ProfileController(this._repo, this._progressRepo);

  final loadState = ProfileLoadState.idle.obs;
  final Rxn<ProfileUser> user = Rxn<ProfileUser>();
  final isEditingName = false.obs;
  final isSavingName = false.obs;
  final nameController = TextEditingController();

  /// Mục tiêu XP/ngày — để chỉnh ngay trong Cài đặt (Hồ sơ).
  final Rxn<DailyGoal> dailyGoal = Rxn<DailyGoal>();
  final savingGoal = false.obs;

  ThemeController get _themeCtrl => Get.find<ThemeController>();
  ThemeMode get themeMode => _themeCtrl.themeMode;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadDailyGoal();
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

  Future<void> loadDailyGoal() async {
    try {
      dailyGoal.value = await _progressRepo.getDailyGoal();
    } catch (_) {
      // Im lặng — tile sẽ hiện mục tiêu mặc định khi chưa tải được.
    }
  }

  /// User đổi mục tiêu XP/ngày từ Cài đặt. Trả true nếu lưu thành công.
  Future<bool> setDailyGoal(int targetXp) async {
    if (savingGoal.value) return false;
    savingGoal.value = true;
    try {
      dailyGoal.value = await _progressRepo.updateDailyGoal(targetXp);
      // Đồng bộ sang màn Progress nếu đang mở → card "XP hôm nay" cập nhật target mới.
      if (Get.isRegistered<ProgressController>()) {
        Get.find<ProgressController>().loadProgress();
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      savingGoal.value = false;
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
      AppNotify.error(T.errorGeneric.tr, message: T.errorUpdateName.tr);
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
          AppButton(
            label: T.actionCancel,
            onPressed: () => Get.back(result: false),
            variant: AppButtonVariant.text,
            expand: false,
            height: 44,
          ),
          AppButton(
            label: T.actionLogout,
            onPressed: () => Get.back(result: true),
            variant: AppButtonVariant.dangerText,
            expand: false,
            height: 44,
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

  /// Cập nhật `totalXp` (và streak nếu vừa được tăng) từ response của 4 endpoint
  /// cộng XP — tránh round-trip GET /profile.
  /// Spec §9.5: FE đọc `response.totalXp` và set thẳng vào ProfileController.
  ///
  /// Bỏ qua nếu profile chưa load (sẽ tự refetch khi user mở Profile).
  void applyXpGrant({
    required int totalXp,
    bool streakUpdated = false,
  }) {
    final current = user.value;
    if (current == null) return;
    if (totalXp <= 0 && !streakUpdated) return;
    user.value = current.copyWith(
      totalXp: totalXp > 0 ? totalXp : current.totalXp,
      currentStreak: streakUpdated
          ? current.currentStreak + 1
          : current.currentStreak,
      longestStreak: streakUpdated
          ? (current.currentStreak + 1 > current.longestStreak
                ? current.currentStreak + 1
                : current.longestStreak)
          : current.longestStreak,
    );
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
