import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/exercise/controllers/exercise_controller.dart';
import 'package:englishme/modules/exercise/models/exercise_model.dart';
import 'package:englishme/theme/app_theme.dart';

class ExerciseResultScreen extends StatelessWidget {
  const ExerciseResultScreen({super.key});

  ExerciseController get controller => Get.find<ExerciseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Làm lại',
                  isTranslate: false,
                  onPressed: controller.retrySession,
                  variant: AppButtonVariant.secondary,
                  radius: AppRadius.pill,
                  height: 54,
                ),
              ),
              AppGap.w12,
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Hoàn thành',
                  isTranslate: false,
                  onPressed: controller.closeExercise,
                  gradient: true,
                  radius: AppRadius.pill,
                  height: 54,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  AppCloseButton(onPressed: controller.closeExercise),
                  AppGap.w8,
                  Text(
                    'Kết quả',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ResultHeader(
                          correct: controller.correctCount,
                          total: controller.totalAnswered,
                        ),
                        AppGap.h20,
                        _ScoreCard(
                          correct: controller.correctCount,
                          total: controller.totalAnswered,
                        ),
                        AppGap.h16,
                        _StatsRow(
                          correct: controller.correctCount,
                          incorrect: controller.totalAnswered - controller.correctCount,
                        ),
                        AppGap.h24,
                        _ReviewSection(results: controller.results),
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

// ─── Result Header ────────────────────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.correct, required this.total});
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? correct / total : 0.0;
    final (icon, title, subtitle) = switch (pct) {
      >= 0.9 => (Icons.emoji_events_rounded, 'Xuất sắc!', 'Bạn đã làm rất tốt!'),
      >= 0.7 => (Icons.thumb_up_rounded, 'Tốt lắm!', 'Bạn đang tiến bộ rõ rệt.'),
      >= 0.5 => (Icons.trending_up_rounded, 'Cố lên!', 'Còn một chút nữa thôi.'),
      _ => (Icons.refresh_rounded, 'Thử lại nhé!', 'Luyện thêm để cải thiện kết quả.'),
    };

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primarySoft,
          ),
          child: Icon(icon, size: 34, color: AppColors.primary),
        ),
        AppGap.h14,
        Text(
          title,
          style: AppTypography.displayLarge.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        AppGap.h6,
        Text(
          subtitle,
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

// ─── Score Card (Donut) ───────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.correct, required this.total});
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? correct / total : 0.0;
    final score = (pct * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _ArcPainter(fraction: pct),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score%',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'ĐIỂM',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.iconMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreLine(
                  label: 'Tổng câu',
                  value: '$total',
                  color: AppColors.primary,
                  icon: Icons.quiz_rounded,
                ),
                AppGap.h12,
                _ScoreLine(
                  label: 'Trả lời đúng',
                  value: '$correct',
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
                AppGap.h12,
                _ScoreLine(
                  label: 'Trả lời sai',
                  value: '${total - correct}',
                  color: AppColors.danger,
                  icon: Icons.cancel_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.fraction});
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (fraction <= 0) return;
    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primary, AppColors.primaryContainer],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      fraction * math.pi * 2,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.fraction != fraction;
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.correct, required this.incorrect});
  final int correct;
  final int incorrect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            label: 'Đúng',
            value: '$correct',
            color: AppColors.success,
            bg: AppColors.successPanel,
          ),
        ),
        AppGap.w12,
        Expanded(
          child: _StatCard(
            icon: Icons.cancel_rounded,
            label: 'Sai',
            value: '$incorrect',
            color: AppColors.danger,
            bg: AppColors.dangerPanel,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          AppGap.w10,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Review Section ───────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.results});
  final List<ExerciseAnswerResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xem lại bài làm',
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppGap.h12,
        ...results.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReviewTile(index: i + 1, result: r),
          );
        }),
      ],
    );
  }
}

class _ReviewTile extends StatefulWidget {
  const _ReviewTile({required this.index, required this.result});
  final int index;
  final ExerciseAnswerResult result;

  @override
  State<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<_ReviewTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final color = r.isCorrect ? AppColors.success : AppColors.danger;
    final bg = r.isCorrect ? AppColors.successPanel : AppColors.dangerPanel;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.index}',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                AppGap.w10,
                Icon(
                  r.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: color,
                  size: 18,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    r.isCorrect ? 'Trả lời đúng' : 'Trả lời sai',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.iconMuted,
                ),
              ],
            ),
            if (_expanded) ...[
              AppGap.h10,
              if (!r.isCorrect) ...[
                _ReviewRow(
                  label: 'Bạn chọn',
                  value: r.selectedAnswer,
                  color: AppColors.danger,
                ),
                AppGap.h6,
              ],
              _ReviewRow(
                label: 'Đáp án đúng',
                value: r.correctAnswer,
                color: AppColors.success,
              ),
              if (r.explanation != null) ...[
                AppGap.h8,
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          r.explanation!,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.iconMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
