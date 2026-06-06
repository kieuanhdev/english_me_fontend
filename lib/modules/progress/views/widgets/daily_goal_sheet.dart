import 'package:englishme/core/utils/app_notify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/progress/models/daily_goal.dart';
import 'package:englishme/theme/app_theme.dart';

/// Bottom sheet cho user tự chọn mục tiêu XP/ngày từ các mức preset.
///
/// Không phụ thuộc controller cụ thể — caller truyền [onSelect] (trả về true nếu
/// lưu thành công) và [isSaving] để khoá nút khi đang lưu. Dùng được ở cả màn
/// Progress lẫn Profile/Cài đặt.
class DailyGoalSheet extends StatelessWidget {
  const DailyGoalSheet({
    super.key,
    required this.goal,
    required this.onSelect,
    required this.isSaving,
  });

  final DailyGoal goal;

  /// Lưu mục tiêu mới. Trả true nếu thành công.
  final Future<bool> Function(int target) onSelect;

  /// Cờ đang lưu (Rx) — để khoá lựa chọn, tránh bấm nhiều lần.
  final RxBool isSaving;

  static Future<void> show(
    BuildContext context, {
    required DailyGoal goal,
    required Future<bool> Function(int target) onSelect,
    required RxBool isSaving,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          DailyGoalSheet(goal: goal, onSelect: onSelect, isSaving: isSaving),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            AppGap.h16,
            Text(
              'Mục tiêu XP mỗi ngày',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppGap.h4,
            Text(
              'Đạt mục tiêu mỗi ngày để nhận +5 XP thưởng và giữ động lực học đều.',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            AppGap.h16,
            Obx(() {
              final saving = isSaving.value;
              return Column(
                children: [
                  for (final option in goal.allowedGoals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GoalOption(
                        goal: option,
                        selected: option == goal.targetXp,
                        disabled: saving,
                        onTap: () => _onSelect(context, option),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _onSelect(BuildContext context, int target) async {
    // Đang chọn đúng mức hiện tại → chỉ đóng sheet.
    if (target == goal.targetXp) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    final ok = await onSelect(target);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (ok) {
      AppNotify.success('Đã cập nhật mục tiêu', message: 'Mục tiêu mỗi ngày: $target XP');
    } else {
      AppNotify.error('Cập nhật thất bại', message: 'Không lưu được mục tiêu, vui lòng thử lại.');
    }
  }
}

class _GoalOption extends StatelessWidget {
  const _GoalOption({
    required this.goal,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final int goal;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled && !selected ? 0.5 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DailyGoal.labelFor(goal),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$goal XP mỗi ngày',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
