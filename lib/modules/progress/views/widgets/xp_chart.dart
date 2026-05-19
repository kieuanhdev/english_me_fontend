import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/theme/app_theme.dart';

class XpChart extends StatelessWidget {
  const XpChart({
    super.key,
    required this.entries,
    required this.maxXp,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final List<WeeklyXpEntry> entries;
  final int maxXp;
  final int selectedRange;
  final ValueChanged<int> onRangeChanged;

  static const _dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XP theo thời gian',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    selectedRange == 0 ? '7 ngày gần đây' : '14 ngày gần đây',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _RangeToggle(
                selected: selectedRange,
                onChanged: onRangeChanged,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: entries.isEmpty
                ? Center(
                    child: Text('Chưa có dữ liệu',
                        style: TextStyle(color: AppColors.textSecondary)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: entries.asMap().entries.map((e) {
                      final i = e.key;
                      final entry = e.value;
                      final ratio = maxXp > 0 ? entry.xp / maxXp : 0.0;
                      final isToday = i == entries.length - 1;
                      final label = _dayLabels[entry.date.weekday % 7];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: i == entries.length - 1 ? 0 : 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isToday && entry.xp > 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${entry.xp}',
                                    style: AppTypography.headlineMedium.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                height: (100 * ratio).clamp(4.0, 100.0),
                                decoration: BoxDecoration(
                                  gradient: isToday
                                      ? AppColors.primaryGradient
                                      : null,
                                  color: isToday
                                      ? null
                                      : entry.xp > 0
                                          ? AppColors.primary
                                              .withValues(alpha: 0.25)
                                          : AppColors.surfaceContainerHigh,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(AppRadius.sm)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                label,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isToday
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tab(label: '7N', selected: selected == 0, onTap: () => onChanged(0)),
          _Tab(label: '14N', selected: selected == 1, onTap: () => onChanged(1)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.onPrimaryFixed : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
