import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/learn/models/learning_models.dart' show XpBonus;
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// Logic chung xử lý kết quả cộng XP từ 4 endpoint (learning/test/exercise/review).
/// Spec §9.5:
///  - FE set thẳng `totalXp` vào ProfileController (không refetch /profile).
///  - Hiển thị toast/snackbar phụ cho từng bonus.
///  - Trigger refresh ProgressController (chart/streak) khi xpEarned > 0.
class XpGrantHandler {
  XpGrantHandler._();

  /// Áp dụng kết quả cộng XP vào state app.
  ///
  /// - [totalXp] / [streakUpdated]: cập nhật ProfileController.
  /// - [bonuses]: hiển thị từng snackbar phụ (nếu có).
  /// - [refreshProgress]: nếu true, gọi ProgressController.loadProgress để
  ///   cập nhật chart/streak calendar (mặc định true khi `xpEarned > 0`).
  static void apply({
    required int totalXp,
    int xpEarned = 0,
    bool streakUpdated = false,
    List<XpBonus> bonuses = const [],
  }) {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().applyXpGrant(
        totalXp: totalXp,
        streakUpdated: streakUpdated,
      );
    }
    if (xpEarned > 0 && Get.isRegistered<ProgressController>()) {
      Get.find<ProgressController>().loadProgress();
    }
    for (final bonus in bonuses) {
      if (bonus.amount <= 0) continue;
      _showBonusToast(bonus);
    }
  }

  static void _showBonusToast(XpBonus bonus) {
    final label = bonus.label.isNotEmpty
        ? bonus.label
        : 'Bonus +${bonus.amount} XP';
    Get.snackbar(
      label,
      '+${bonus.amount} XP',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      borderRadius: AppRadius.md,
      backgroundColor: AppColors.success,
      colorText: AppColors.onPrimaryFixed,
      icon: Icon(
        Icons.emoji_events_rounded,
        color: AppColors.onPrimaryFixed,
      ),
      duration: const Duration(seconds: 2),
      shouldIconPulse: false,
    );
  }
}
