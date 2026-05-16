import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/theme/app_theme.dart';

class SkillRadarChart extends StatelessWidget {
  const SkillRadarChart({super.key, required this.skill});

  final SkillBreakdown skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích kỹ năng',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _RadarPainter(
                  values: [
                    skill.vocabulary,
                    skill.grammar,
                    skill.pronunciation,
                    skill.listening,
                  ],
                  fillColor: AppColors.primary.withValues(alpha: 0.2),
                  strokeColor: AppColors.primary,
                  gridColor: AppColors.outlineVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SkillBar(
            label: 'Từ vựng',
            value: skill.vocabulary,
            color: AppColors.skillVocabulary,
          ),
          const SizedBox(height: 10),
          _SkillBar(
            label: 'Ngữ pháp',
            value: skill.grammar,
            color: AppColors.skillGrammar,
          ),
          const SizedBox(height: 10),
          _SkillBar(
            label: 'Phát âm',
            value: skill.pronunciation,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _SkillBar(
            label: 'Nghe hiểu',
            value: skill.listening,
            color: AppColors.skillListening,
          ),
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values; // 4 values 0..1
  final Color fillColor;
  final Color strokeColor;
  final Color gridColor;

  const _RadarPainter({
    required this.values,
    required this.fillColor,
    required this.strokeColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;
    final n = values.length;
    final angleStep = (2 * math.pi) / n;
    const startAngle = -math.pi / 2;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid rings
    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = startAngle + i * angleStep;
        final p = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axes
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        gridPaint,
      );
    }

    // Draw data
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * values[i].clamp(0.0, 1.0);
      final p = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * values[i].clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
        3.5,
        dotPaint,
      );
    }

    // Labels
    final labels = ['Từ vựng', 'Ngữ pháp', 'Phát âm', 'Nghe'];
    final textStyle = TextStyle(
      fontFamily: 'BeVietnamPro',
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: gridColor,
    );
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final labelRadius = radius + 14;
      final p = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.values != values || old.fillColor != fillColor;
}
