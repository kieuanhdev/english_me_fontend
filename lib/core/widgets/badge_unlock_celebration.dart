import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/confetti_overlay.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart' show BadgeAward;
import 'package:englishme/theme/app_theme.dart';

/// Dialog ăn mừng khi user MỞ KHOÁ thành tích (badge). Trước đây badge chỉ hiện
/// trong hồ sơ → user không biết vừa đạt. Giờ mọi luồng kiếm XP trả về newBadges
/// và gọi [showQueue] để hiện popup ngay.
///
/// Nhiều badge cùng lúc → hiện TUẦN TỰ (đóng cái này mở cái kế) để không chồng.
class BadgeUnlockCelebration extends StatelessWidget {
  const BadgeUnlockCelebration({super.key, required this.badge});

  final BadgeAward badge;

  /// Hiện lần lượt danh sách badge vừa mở khoá. Hoãn tới sau frame để an toàn khi
  /// caller vừa điều hướng (vd sang màn kết quả). Bỏ qua nếu rỗng.
  static void showQueue(List<BadgeAward> badges) {
    if (badges.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAt(badges, 0));
  }

  static void _showAt(List<BadgeAward> badges, int index) {
    if (index >= badges.length) return;
    if (Get.isDialogOpen ?? false) return; // có dialog khác → nhường, không chồng.
    Get.dialog(
      BadgeUnlockCelebration(badge: badges[index]),
      barrierColor: Colors.black.withValues(alpha: 0.55),
    ).then((_) => _showAt(badges, index + 1)); // đóng → mở badge kế.
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: IgnorePointer(child: ConfettiOverlay())),
        _buildDialog(),
      ],
    );
  }

  Widget _buildDialog() {
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
            const _PoppingMedal(),
            AppGap.h20,
            Text(
              '🏆 Mở khoá thành tích!',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 22,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppGap.h10,
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            if (badge.description.isNotEmpty) ...[
              AppGap.h6,
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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

/// Huy chương phóng to nảy (elasticOut) rồi đứng yên. Ảnh icon từ URL nếu có,
/// fallback icon huy chương mặc định.
class _PoppingMedal extends StatelessWidget {
  const _PoppingMedal();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.military_tech_rounded,
          color: AppColors.primary,
          size: 56,
        ),
      ),
    );
  }
}
