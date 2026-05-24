import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_desk_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabStats extends GetView<VocabDeskController> {
  const VocabStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _StatCard(
                  iconBg: AppColors.secondaryContainer,
                  iconColor: AppColors.primary,
                  icon: Icons.bolt_rounded,
                  value: '${controller.dayStreak.value}',
                  label: 'Day Streak',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  iconBg: AppColors.levelCBg,
                  iconColor: AppColors.tertiary,
                  icon: Icons.psychology_rounded,
                  value: '${controller.avgMastery.value}%',
                  label: 'Avg. Mastery',
                ),
              ),
            ],
          )),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(color: AppColors.neutralShadow, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.displayLarge.copyWith(fontSize: 28, color: AppColors.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodyLarge.copyWith(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
