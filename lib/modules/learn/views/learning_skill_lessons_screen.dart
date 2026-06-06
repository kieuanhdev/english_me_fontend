import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/modules/learn/repositories/learning_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class LearningSkillLessonsScreen extends StatelessWidget {
  const LearningSkillLessonsScreen({
    super.key,
    required this.level,
    required this.skill,
  });

  final String level;
  final String skill;

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<LearningRepository>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FutureBuilder<LearningSkillLessons>(
          future: repo.getSkillLessons(level: level, skill: skill),
          builder: (context, snapshot) {
            final state = snapshot.connectionState == ConnectionState.waiting
                ? ApiState.loading
                : snapshot.hasError
                ? ApiState.error
                : snapshot.data == null || snapshot.data!.lessons.isEmpty
                ? ApiState.empty
                : ApiState.success;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ApiStateView(
                state: state,
                errorMessage: 'Không tải được danh sách bài học.',
                emptyMessage: 'Kỹ năng này chưa có bài học.',
                onRetry: () => Get.offNamed(
                  AppRoutes.learningSkillLessons,
                  arguments: {'level': level, 'skill': skill},
                ),
                builder: (_) {
                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppMainAppBar(
                        title: data.title,
                        subtitle: data.description,
                        showBack: true,
                        showSettings: false,
                        showNotification: false,
                        horizontalPadding: 0,
                        onBack: Get.back,
                      ),
                      AppGap.h20,
                      Expanded(
                        child: ListView.separated(
                          itemCount: data.lessons.length,
                          separatorBuilder: (_, __) => AppGap.h10,
                          itemBuilder: (_, index) => _LessonTile(
                            lesson: data.lessons[index],
                            skill: data.skill,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.skill});

  final LearningLessonListItem lesson;
  final String skill;

  @override
  Widget build(BuildContext context) {
    final color = _skillColor(skill);
    final disabled = lesson.isLocked || lesson.isCompleted;
    return Material(
      color: disabled
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: disabled
            ? null
            : () => Get.toNamed(
                AppRoutes.curriculumLessonPlayer,
                arguments: {'lessonId': lesson.id},
              ),
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
                child: Icon(_statusIcon(lesson), color: color, size: 23),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    AppGap.h8,
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.timer_outlined,
                          label: '${lesson.durationMinutes} phút',
                        ),
                        AppGap.w8,
                        _MetaChip(
                          icon: Icons.bolt_rounded,
                          label: '+${lesson.xpReward} XP',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                lesson.isCompleted
                    ? Icons.check_circle_rounded
                    : lesson.isLocked
                    ? Icons.lock_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.iconMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelXSmall),
      ],
    );
  }
}

IconData _statusIcon(LearningLessonListItem lesson) {
  if (lesson.isCompleted) return Icons.check_rounded;
  if (lesson.isLocked) return Icons.lock_rounded;
  if (lesson.status == 'in_progress') return Icons.play_arrow_rounded;
  return Icons.school_rounded;
}

Color _skillColor(String skill) {
  return switch (skill) {
    'listening' => AppColors.skillListening,
    'speaking' => AppColors.tertiary,
    'reading' => AppColors.success,
    'writing' => AppColors.primary,
    _ => AppColors.primary,
  };
}
