import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/confetti_overlay.dart';
import 'package:englishme/theme/app_theme.dart';

/// Dialog chúc mừng khi user đạt mục tiêu XP trong ngày (daily_goal_bonus).
/// Icon cúp phóng to nảy nhẹ (bounce) + fade, thuần Flutter, không thêm package.
class DailyGoalCelebration extends StatelessWidget {
  const DailyGoalCelebration({super.key, required this.bonusXp, this.label});

  /// XP thưởng nhận được (vd 5).
  final int bonusXp;

  /// Nhãn từ backend (nếu có) — vd "Đạt mục tiêu ngày (30 XP)".
  final String? label;

  /// Hiển thị dialog. Hoãn tới sau frame hiện tại để an toàn khi caller vừa
  /// điều hướng (vd Get.offNamed sang màn kết quả ngay sau khi cộng XP) —
  /// nếu mở ngay, dialog sẽ bị nuốt bởi chuyển trang. Bỏ qua nếu đang có dialog
  /// khác mở (tránh chồng).
  static void show({required int bonusXp, String? label}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen ?? false) return;
      Get.dialog(
        DailyGoalCelebration(bonusXp: bonusXp, label: label),
        barrierColor: Colors.black.withValues(alpha: 0.55),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = (label != null && label!.isNotEmpty)
        ? label!
        : 'Đạt mục tiêu hôm nay!';
    // Confetti rơi phủ toàn màn phía sau dialog (không chặn tương tác nút).
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(child: ConfettiOverlay()),
        ),
        _buildDialog(title),
      ],
    );
  }

  Widget _buildDialog(String title) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BouncingTrophy(),
            AppGap.h20,
            Text(
              '🎉 Chúc mừng!',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 22,
                color: AppColors.onSurface,
              ),
            ),
            AppGap.h8,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            AppGap.h16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.statBgWarm,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded,
                      color: AppColors.statFgWarm, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '+$bonusXp XP thưởng',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statFgWarm,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h24,
            AppButton(
              label: 'Tuyệt vời!',
              isTranslate: false,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cúp vàng phóng to nảy nhẹ rồi đứng yên.
class _BouncingTrophy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.statBgWarm,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.emoji_events_rounded,
          color: AppColors.statFgWarm,
          size: 48,
        ),
      ),
    );
  }
}
