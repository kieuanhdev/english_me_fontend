import 'package:flutter/material.dart';
import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/theme/app_theme.dart';

class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({super.key, required this.summary});

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final hours = summary.minutesStudied ~/ 60;
    final mins = summary.minutesStudied % 60;
    final timeLabel = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    final accuracyPct = (summary.accuracyRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt tuần này',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  icon: Icons.schedule_rounded,
                  value: timeLabel,
                  label: 'Thời gian học',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCell(
                  icon: Icons.check_circle_outline_rounded,
                  value: '${summary.exercisesCompleted}',
                  label: 'Bài hoàn thành',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  icon: Icons.bar_chart_rounded,
                  value: '$accuracyPct%',
                  label: 'Độ chính xác',
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCell(
                  icon: Icons.style_rounded,
                  value: '${summary.flashcardsReviewed}',
                  label: 'Thẻ đã ôn',
                  color: AppColors.skillVocabulary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
