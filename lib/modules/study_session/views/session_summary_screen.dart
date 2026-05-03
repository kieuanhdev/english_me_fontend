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
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Hoàn thành',
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
                          mastered: controller.masteredCount.value,
                          remember: controller.rememberCount.value,
                          vague: controller.vagueCount.value,
                          forget: controller.forgetCount.value,
                          total: controller.totalReviewed,
                        ),
                        AppGap.h16,
                        // Streak card
                        _StreakCard(days: controller.streakDays.value),
                        AppGap.h12,
                        // XP card
                        _XpCard(
                          xp: controller.xpEarned.value,
                          level: controller.currentLevel.value,
                          progress: controller.xpProgress.value,
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
            color: const Color(0xFFFFDCBE).withValues(alpha: 0.6),
          ),
          child: const Icon(Icons.celebration_rounded, size: 34, color: Color(0xFF854d00)),
        ),
        AppGap.h16,
        const Text(
          'Tuyệt vời!',
          style: TextStyle(
            fontFamily: 'BeVietnamPro',
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
        borderRadius: BorderRadius.circular(28),
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
                    colors: const [
                      AppColors.primary,
                      Color(0xFF854d00),
                      Color(0xFF565C84),
                      Color(0xFF9EA8B3),
                    ],
                    empty: total == 0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontFamily: 'BeVietnamPro',
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
              _LegendTile(color: const Color(0xFF854d00), label: 'REMEMBER', count: remember),
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
        ..color = const Color(0xFFE2E2E2)
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 34,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
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
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
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

// ─── Streak Card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x061A1C1C), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFFFDCBE).withValues(alpha: 0.5),
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFF854d00), size: 26),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chuỗi $days ngày',
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Bạn đang giữ phong độ rất tốt!',
                  style: AppTypography.bodyLarge.copyWith(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Text(
            '+1',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF854d00),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Card ─────────────────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  const _XpCard({required this.xp, required this.level, required this.progress});
  final int xp, level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.07), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x061A1C1C), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.secondaryContainer.withValues(alpha: 0.45),
            ),
            child: const Icon(Icons.military_tech_rounded, color: AppColors.primary, size: 26),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kinh nghiệm',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                AppGap.h8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: AppColors.surfaceContainerHigh),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.w16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$xp XP',
                style: const TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'LEVEL $level',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.iconMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
