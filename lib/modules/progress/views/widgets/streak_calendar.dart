import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({
    super.key,
    required this.studyDates,
    required this.currentStreak,
    required this.longestStreak,
  });

  final List<DateTime> studyDates;
  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month);
    final firstWeekday = startDay.weekday % 7; // 0=Sun … 6=Sat
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final studySet = {
      for (final d in studyDates) DateTime(d.year, d.month, d.day),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.tertiary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Streak học tập',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              _StreakChip(label: '🔥 $currentStreak ngày', isHighlight: true),
            ],
          ),
          const SizedBox(height: 16),
          // Weekday headers
          Row(
            children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineMedium.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final date = DateTime(now.year, now.month, day);
              final isToday = day == now.day;
              final isStudied = studySet.contains(date);
              final isFuture = date.isAfter(now);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : isStudied
                      ? AppColors.tertiary.withValues(alpha: 0.2)
                      : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: isStudied && !isToday
                      ? Border.all(
                          color: AppColors.tertiary.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: isFuture
                    ? null
                    : isStudied
                    ? (isToday
                          ? Text(
                              '$day',
                              style: AppTypography.headlineMedium.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onPrimaryFixed,
                              ),
                            )
                          : Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.tertiary,
                            ))
                    : Text(
                        '$day',
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppColors.onPrimaryFixed
                              : AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(
                color: AppColors.tertiary.withValues(alpha: 0.5),
                label: 'Đã học',
              ),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.primary, label: 'Hôm nay'),
              const Spacer(),
              Text(
                'Dài nhất: $longestStreak ngày',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.label, this.isHighlight = false});
  final String label;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.tertiary.withValues(alpha: 0.15)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.headlineMedium.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isHighlight ? AppColors.tertiary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
