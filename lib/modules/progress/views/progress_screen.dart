import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/modules/progress/views/widgets/skill_radar.dart';
import 'package:englishme/modules/progress/views/widgets/streak_calendar.dart';
import 'package:englishme/modules/progress/views/widgets/weekly_summary_card.dart';
import 'package:englishme/modules/progress/views/widgets/xp_chart.dart';
import 'package:englishme/theme/app_theme.dart';

class ProgressScreen extends GetView<ProgressController> {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          if (controller.loadState.value == ProgressLoadState.loading) {
            return const _LoadingState();
          }
          if (controller.loadState.value == ProgressLoadState.error) {
            return _ErrorState(onRetry: controller.loadProgress);
          }
          final data = controller.data.value;
          if (data == null) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: controller.loadProgress,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppMainAppBar(title: 'Tiến trình'),
                  AppGap.h6,
                  Text(
                    'Theo dõi hành trình học tiếng Anh của bạn',
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Trình độ hiện tại',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.textSecondary,
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
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.cefrLabel,
              style: const TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.tertiaryFixedDim, size: 18),
              const SizedBox(width: 4),
              Text(
                'XP hôm nay',
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 12,
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
              borderRadius: BorderRadius.circular(999),
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
            'Tổng: ${data.totalXp} XP',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMax ? 'Bạn đã đạt trình độ cao nhất!' : 'Sẵn sàng lên $next?',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          AppGap.h6,
          Text(
            isMax
                ? 'Tiếp tục duy trì và ôn luyện để giữ vững trình độ C2.'
                : 'Hoàn thành thêm bài tập phát âm và từ vựng để nâng cấp trình độ CEFR của bạn.',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          AppGap.h14,
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isMax ? 'Ôn luyện ngay' : 'Bắt đầu luyện tập',
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 13,
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

// ─── States ───────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          AppGap.h16,
          Text(
            'Đang tải tiến trình...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_off_rounded,
                size: 56, color: AppColors.textSecondary),
            AppGap.h16,
            Text(
              'Không thể tải dữ liệu',
              style: AppTypography.headlineMedium
                  .copyWith(color: AppColors.onSurface),
            ),
            AppGap.h8,
            Text(
              'Kiểm tra kết nối mạng và thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            AppGap.h20,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
