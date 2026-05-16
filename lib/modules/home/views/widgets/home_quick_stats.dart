import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeQuickStats extends GetView<HomeController> {
  const HomeQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF6B35),
            bgColor: const Color(0xFFFFF0E8),
            value: '${controller.streakDays.value}',
            label: 'Ngày liên tiếp',
          ),
          AppGap.w10,
          _StatCard(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.primarySoft,
            value: '${controller.xpToday.value}',
            label: 'XP hôm nay',
          ),
          AppGap.w10,
          _StatCard(
            icon: Icons.style_rounded,
            iconColor: const Color(0xFF00897B),
            bgColor: const Color(0xFFE0F2F1),
            value: '${controller.cardsLearned.value}',
            label: 'Thẻ đã học',
          ),
          AppGap.w10,
          _StatCard(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF6750A4),
            bgColor: const Color(0xFFEEE8F8),
            value: '${controller.exerciseDone.value}',
            label: 'Bài tập',
          ),
        ],
      )),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 18,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
