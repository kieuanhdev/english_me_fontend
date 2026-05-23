import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/modules/progress/views/widgets/skill_radar.dart';
import 'package:englishme/modules/progress/views/widgets/streak_calendar.dart';
import 'package:englishme/modules/progress/views/widgets/weekly_summary_card.dart';
import 'package:englishme/modules/progress/views/widgets/xp_chart.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';

class ProgressScreen extends GetView<ProgressController> {
  const ProgressScreen({super.key});

  ApiState _mapState(ProgressLoadState s, ProgressController c) {
    switch (s) {
      case ProgressLoadState.idle:
      case ProgressLoadState.loading:
        return ApiState.loading;
      case ProgressLoadState.error:
        return ApiState.error;
      case ProgressLoadState.success:
        return c.data.value == null ? ApiState.empty : ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _mapState(controller.loadState.value, controller),
            errorMessage: T.errorLoadProgress.tr,
            emptyMessage: T.emptyProgress.tr,
            onRetry: controller.loadProgress,
            builder: (_) {
              final data = controller.data.value!;
              return RefreshIndicator(
            onRefresh: controller.loadProgress,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppMainAppBar(title: T.navProgress.tr, horizontalPadding: 0),
                  AppGap.h6,
                  Text(
                    T.progressSubtitle.tr,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  AppGap.h20,
                  _HeroRow(data: data),
                  AppGap.h16,
                  Obx(() => XpChart(
                    entries: controller.chartEntries,
                    maxXp: controller.chartMaxXp,
                    selectedRange: controller.selectedChartRange.value,
                    onRangeChanged: controller.selectChartRange,
                  )),
                  AppGap.h16,
                  StreakCalendar(
                    studyDates: data.studyDates,
                    currentStreak: data.currentStreak,
                    longestStreak: data.longestStreak,
                  ),
                  AppGap.h16,
                  SkillRadarChart(skill: data.skillBreakdown),
                  AppGap.h16,
                  WeeklySummaryCard(summary: data.weeklySummary),
                  AppGap.h16,
                  _NextLevelCard(data: data),
                ],
              ),
            ),
          );
            },
          );
        }),
      ),
    );
  }
}

// ─── Hero Row ─────────────────────────────────────────────────────────────────

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.data});
  final ProgressData data;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _LevelCard(data: data)),
          AppGap.w12,
          Expanded(child: _XpTodayCard(data: data)),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.data});
  final ProgressData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        children: [
          Text(
            T.progressCurrentLevel.tr,
            style: AppTypography.labelXSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          AppGap.h10,
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              data.cefrLevel,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 32,
                color: AppColors.primary,
              ),
            ),
          ),
          AppGap.h8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              data.cefrLabel,
              style: AppTypography.labelXSmall.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.onPrimaryFixed,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpTodayCard extends StatelessWidget {
  const _XpTodayCard({required this.data});
  final ProgressData data;

  @override
  Widget build(BuildContext context) {
    final progress = data.xpGoal > 0
        ? (data.todayXp / data.xpGoal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.tertiaryFixedDim, size: 18),
              const SizedBox(width: 4),
              Text(
                T.progressXpToday.tr,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          AppGap.h6,
          RichText(
            text: TextSpan(
              text: '${data.todayXp}',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 30,
                color: AppColors.primary,
              ),
              children: [
                TextSpan(
                  text: ' / ${data.xpGoal}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppGap.h8,
          SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          AppGap.h8,
          Text(
            T.progressTotalXp.tr.replaceAll('@xp', '${data.totalXp}'),
            style: AppTypography.labelXSmall.copyWith(),
          ),
        ],
      ),
    );
  }
}

// ─── Next Level Card ──────────────────────────────────────────────────────────

class _NextLevelCard extends StatelessWidget {
  const _NextLevelCard({required this.data});
  final ProgressData data;

  static const _nextLevel = {
    'A1': 'A2', 'A2': 'B1', 'B1': 'B2', 'B2': 'C1', 'C1': 'C2', 'C2': 'C2',
  };

  @override
  Widget build(BuildContext context) {
    final next = _nextLevel[data.cefrLevel] ?? 'C2';
    final isMax = data.cefrLevel == 'C2';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMax ? T.progressMaxLevel.tr : T.progressReadyFor.tr.replaceAll('@next', next),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 22,
              color: AppColors.onPrimaryFixed,
            ),
          ),
          AppGap.h6,
          Text(
            isMax
                ? T.progressMaxLevelDesc.tr
                : T.progressPromoteDesc.tr,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          AppGap.h14,
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.onPrimaryFixed,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                isMax ? T.progressKeepLearning.tr : T.progressStartPractice.tr,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
