import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_settings_icon_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _onBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
      return;
    }
    ShellController.goToTab(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: AppBottomNav(
        initialIndex: 4,
        onTap: (index, _) => ShellController.goToTab(index),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: _onBack),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Your Progress',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const AppSettingsIconButton(),
                ],
              ),
              AppGap.h20,
              const _HeroSection(),
              AppGap.h16,
              const _StudyActivityCard(),
              AppGap.h16,
              const _AchievementsGrid(),
              AppGap.h16,
              const _NextLevelCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(
                  'Current Proficiency',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                AppGap.h12,
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 6,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'A2',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 42,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                AppGap.h8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'PRE-INTERMEDIATE',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppGap.w12,
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.tertiaryFixedDim,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '7 Day Streak',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                AppGap.h8,
                Text(
                  'Keep the flame burning!',
                  style: AppTypography.headlineMedium.copyWith(fontSize: 24),
                ),
                AppGap.h20,
                Row(
                  children: List.generate(
                    7,
                    (i) => Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: i == 6 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: i == 6
                              ? [
                                  BoxShadow(
                                    color: AppColors.tertiary.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StudyActivityCard extends StatelessWidget {
  const _StudyActivityCard();

  @override
  Widget build(BuildContext context) {
    final values = [0.4, 0.65, 0.3, 0.85, 0.55, 0.45, 0.2];
    final labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Activity',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Last 7 days',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  text: '12.4',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 28,
                    color: AppColors.primary,
                  ),
                  children: [
                    TextSpan(
                      text: ' hrs',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h16,
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(labels.length, (i) {
                final isPeak = i == 3;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 100 * values[i],
                          decoration: BoxDecoration(
                            gradient: isPeak ? AppColors.primaryGradient : null,
                            color: isPeak
                                ? null
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                        ),
                        AppGap.h8,
                        Text(
                          labels[i],
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isPeak ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Early Bird', Icons.auto_awesome, true),
      ('7 Day King', Icons.military_tech, true),
      ('Polyglot', Icons.lock, false),
      ('Chat Master', Icons.forum, true),
      ('Brainiac', Icons.psychology, false),
      ('Orator', Icons.campaign, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
            Text(
              'View All',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        AppGap.h10,
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.84,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final unlocked = item.$3;
            return Container(
              decoration: BoxDecoration(
                color: unlocked
                    ? AppColors.surfaceContainerLowest
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? AppColors.tertiary.withValues(alpha: 0.2)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.$2,
                      size: 28,
                      color: unlocked ? AppColors.tertiary : AppColors.iconMuted,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    item.$1,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: unlocked ? AppColors.onSurface : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NextLevelCard extends StatelessWidget {
  const _NextLevelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready for B1?',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          AppGap.h8,
          Text(
            'Complete 4 more pronunciation units to level up your English proficiency.',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          AppGap.h14,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Start Next Unit',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
