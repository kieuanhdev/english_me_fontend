import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/learn/controllers/unit_detail_controller.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/views/unit_list_screen.dart'
    show skillColor, skillIcon, skillLabel;
import 'package:englishme/theme/app_theme.dart';

class UnitDetailScreen extends GetView<UnitDetailController> {
  const UnitDetailScreen({super.key});

  ApiState _stateOf() {
    if (controller.loading.value) return ApiState.loading;
    return controller.unit.value == null ? ApiState.empty : ApiState.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(() {
            return ApiStateView(
              state: _stateOf(),
              errorMessage: 'Không tải được Unit.',
              emptyMessage: 'Unit này chưa có bài học.',
              onRetry: controller.load,
              builder: (_) {
                final u = controller.unit.value!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppBackButton(onPressed: () {
                          if (Get.key.currentState?.canPop() ?? false) {
                            Get.back();
                          } else {
                            ShellController.goToTab(1);
                          }
                        }),
                        AppGap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.title,
                                style: AppTypography.displayLarge.copyWith(
                                  fontSize: 20,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppGap.h2,
                              Text(
                                '${u.level} • ${u.totalLessons} bài học',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppGap.h16,
                    _UnitHeader(unit: u),
                    AppGap.h16,
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: u.lessons.length,
                        separatorBuilder: (_, __) => AppGap.h10,
                        itemBuilder: (_, index) => _LessonTile(
                          lesson: u.lessons[index],
                          onTap: () =>
                              controller.openLesson(u.lessons[index]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({required this.unit});
  final UnitDetail unit;

  @override
  Widget build(BuildContext context) {
    final progress =
        unit.totalLessons == 0 ? 0.0 : unit.completedLessonCount / unit.totalLessons;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.route_rounded, color: AppColors.primary),
              ),
              AppGap.w12,
              Expanded(
                child: Text(
                  unit.subtitle,
                  style: AppTypography.bodyRegular,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppGap.h14,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          AppGap.h8,
          Text(
            '${unit.completedLessonCount}/${unit.totalLessons} bài hoàn thành',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.onTap});
  final LessonListItem lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = lesson.isLocked;
    final color = disabled ? AppColors.iconMuted : skillColor(lesson.skill);
    final IconData statusIcon = lesson.isCompleted
        ? Icons.check_rounded
        : disabled
            ? Icons.lock_rounded
            : skillIcon(lesson.skill);

    return Material(
      color: disabled
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(statusIcon, color: color, size: 23),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _SkillPill(skill: lesson.skill, color: color),
                        AppGap.w8,
                        Text('${lesson.durationMinutes} phút',
                            style: AppTypography.labelXSmall),
                        if (lesson.theoryViewed) ...[
                          AppGap.w8,
                          Icon(Icons.menu_book_rounded,
                              size: 13, color: AppColors.textSecondary),
                        ],
                      ],
                    ),
                    AppGap.h8,
                    Text(
                      '${lesson.order}. ${lesson.title}',
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      lesson.subtitle,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lesson.bestScore > 0) ...[
                      AppGap.h6,
                      Text(
                        'Điểm cao nhất: ${lesson.bestScore}%',
                        style: AppTypography.labelXSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppGap.w8,
              Icon(
                lesson.isCompleted
                    ? Icons.check_circle_rounded
                    : disabled
                        ? Icons.lock_rounded
                        : Icons.chevron_right_rounded,
                color: lesson.isCompleted
                    ? AppColors.success
                    : AppColors.iconMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.skill, required this.color});
  final String skill;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        skillLabel(skill),
        style: AppTypography.labelXSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
