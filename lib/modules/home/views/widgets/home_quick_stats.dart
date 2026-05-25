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
      child: Obx(() {
        controller.dashboard.value;
        return IntrinsicHeight(
          child: Row(
            children: [
              _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.statFgWarm,
                bgColor: AppColors.statBgWarm,
                value: '${controller.streakDays}',
                label: 'Ngày liên tiếp',
              ),
              AppGap.w10,
              _StatCard(
                icon: Icons.bolt_rounded,
                iconColor: AppColors.primary,
                bgColor: AppColors.primarySoft,
                value: '${controller.xpToday}',
                label: 'XP hôm nay',
              ),
              AppGap.w10,
              _StatCard(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.statFgCool,
                bgColor: AppColors.statBgCool,
                value: '${controller.activeDaysThisWeek}',
                label: 'Ngày học/tuần',
              ),
              AppGap.w10,
              _StatCard(
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF6750A4),
                bgColor: const Color(0xFFEEE8F8),
                value: '${controller.xpWeek}',
                label: 'XP tuần này',
              ),
            ],
          ),
        );
      }),
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
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
              maxLines: 2,
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
