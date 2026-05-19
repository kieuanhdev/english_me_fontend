import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  StudySessionController get controller => Get.find<StudySessionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GestureDetector(
            onTap: controller.closeSession,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              alignment: Alignment.center,
              child: Text(
                'Hoàn thành',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.closeSession,
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: AppColors.primary,
                  ),
                  Text(
                    'Daily Session',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_rounded, size: 22),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Celebration header
                        _CelebrationHeader(),
                        AppGap.h24,
                        // Donut + legend
                        _DonutCard(
                          mastered: controller.summary.value?.masteredCards ??
                              controller.masteredCount.value,
                          remember: controller.rememberCount.value,
                          vague: controller.summary.value?.hardCards ??
                              controller.vagueCount.value,
                          forget: controller.summary.value?.againCards ??
                              controller.forgetCount.value,
                          total: controller.totalReviewed,
                        ),
                        AppGap.h16,
                        // New words card
                        _NewWordsCard(
                          count: controller.summary.value?.newWordsLearned ?? 0,
                        ),
                        AppGap.h12,
                        // XP card
                        _XpCard(
                          xp: controller.summary.value?.xpEarned ??
                              controller.sessionXp.value,
                        ),
                        AppGap.h32,
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Celebration Header ───────────────────────────────────────────────────────

class _CelebrationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.levelCBg.withValues(alpha: 0.6),
          ),
          child: Icon(Icons.celebration_rounded, size: 34, color: AppColors.accentWarm),
        ),
        AppGap.h16,
        Text(
          'Tuyệt vời!',
          style: AppTypography.displayLarge.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        AppGap.h8,
        Text(
          'Bạn đã hoàn thành mục tiêu ngày hôm nay.',
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Donut Card ───────────────────────────────────────────────────────────────

class _DonutCard extends StatelessWidget {
  const _DonutCard({
    required this.mastered,
    required this.remember,
    required this.vague,
    required this.forget,
    required this.total,
  });

  final int mastered, remember, vague, forget, total;

  @override
  Widget build(BuildContext context) {
    final display = total == 0 ? 1 : total;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        children: [
          // Donut
          SizedBox(
            width: 176,
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(176, 176),
                  painter: _DonutPainter(
                    fractions: [
                      mastered / display,
                      remember / display,
                      vague / display,
                      forget / display,
                    ],
                    colors: [
                      AppColors.primary,
                      AppColors.accentWarm,
                      const Color(0xFF565C84),
                      AppColors.iconMuted,
                    ],
                    empty: total == 0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'THẺ ĐÃ ÔN',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.iconMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppGap.h24,
          // 2×2 legend grid
          Row(
            children: [
              _LegendTile(color: AppColors.primary, label: 'MASTERED', count: mastered),
              AppGap.w12,
              _LegendTile(color: AppColors.accentWarm, label: 'REMEMBER', count: remember),
            ],
          ),
          AppGap.h12,
          Row(
            children: [
              _LegendTile(color: const Color(0xFF565C84), label: 'VAGUE', count: vague),
              AppGap.w12,
              _LegendTile(color: AppColors.iconMuted, label: 'FORGET', count: forget),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.fractions,
    required this.colors,
    required this.empty,
  });

  final List<double> fractions;
  final List<Color> colors;
  final bool empty;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.115;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);

    // track
    canvas.drawArc(
      rect, 0, math.pi * 2, false,
      Paint()
        ..color = AppColors.surfaceContainerHigh
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (empty) return;

    double start = -math.pi / 2;
    const gap = 0.05;

    for (int i = 0; i < fractions.length; i++) {
      final f = fractions[i];
      if (f <= 0) continue;
      final sweep = f * math.pi * 2 - gap;
      if (sweep <= 0) continue;
      canvas.drawArc(
        rect,
        start + gap / 2,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 2
          ..strokeCap = StrokeCap.round,
      );
      start += f * math.pi * 2;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.fractions != fractions;
}

class _LegendTile extends StatelessWidget {
  const _LegendTile({required this.color, required this.label, required this.count});
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 34,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.pill)),
            ),
            AppGap.w12,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.iconMuted,
                  ),
                ),
                Text(
                  '$count',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── New Words Card ───────────────────────────────────────────────────────────

class _NewWordsCard extends StatelessWidget {
  const _NewWordsCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [BoxShadow(color: AppColors.shadowSoft, blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColors.levelCBg.withValues(alpha: 0.5),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: AppColors.accentWarm, size: 26),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Từ mới hôm nay',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Số từ lần đầu bạn ôn trong session này.',
                  style: AppTypography.bodyLarge.copyWith(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '+$count',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.accentWarm,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Card ─────────────────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  const _XpCard({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.07), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.shadowSoft, blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColors.secondaryContainer.withValues(alpha: 0.45),
            ),
            child: Icon(Icons.military_tech_rounded, color: AppColors.primary, size: 26),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kinh nghiệm session',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'XP cộng từ SM-2 (quality 5: +3, q∈{3,4}: +2).',
                  style: AppTypography.bodyLarge.copyWith(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          AppGap.w16,
          Text(
            '+$xp XP',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
