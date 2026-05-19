import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/modules/grammar/models/grammar_models.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/grammar/controllers/grammar_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GrammarScreen extends GetView<GrammarController> {
  const GrammarScreen({super.key});

  ApiState get _topicsState {
    if (controller.isLoadingTopics.value) return ApiState.loading;
    if (controller.error.value.isNotEmpty && controller.topics.isEmpty) return ApiState.error;
    if (controller.topics.isEmpty) return ApiState.empty;
    return ApiState.success;
  }

  ApiState get _lessonsState {
    if (controller.isLoadingLessons.value) return ApiState.loading;
    if (controller.error.value.isNotEmpty && controller.lessons.isEmpty) return ApiState.error;
    if (controller.lessons.isEmpty) return ApiState.empty;
    return ApiState.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: AppBottomNav(
        initialIndex: 1,
        onTap: (index, _) => ShellController.goToTab(index),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(title: T.titleGrammar.tr),
              AppGap.h20,
              Text(
                T.descGrammarTopics.tr,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                ),
              ),
              AppGap.h8,
              Text(
                T.descGrammarHint.tr,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppGap.h16,
              Expanded(
                child: Obx(() {
                  return ApiStateView(
                    state: _topicsState,
                    errorMessage: controller.error.value,
                    emptyMessage: T.emptyGrammarTopics.tr,
                    onRetry: controller.loadTopics,
                    builder: (_) => Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: Obx(() => ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) {
                              final topic = controller.topics[index];
                              final selected =
                                  controller.selectedTopic.value?.id == topic.id;
                              return _TopicChip(
                                label: '${topic.category} • ${topic.level}',
                                selected: selected,
                                onTap: () => controller.selectTopic(topic),
                              );
                            },
                            separatorBuilder: (_, __) => AppGap.w8,
                            itemCount: controller.topics.length,
                          )),
                        ),
                        AppGap.h16,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Obx(() {
                            final topic = controller.selectedTopic.value;
                            return Text(
                              topic == null
                                  ? T.labelLessons.tr
                                  : '${topic.title} (${topic.lessonCount} ${T.labelLessons.tr.toLowerCase()})',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            );
                          }),
                        ),
                        AppGap.h10,
                        Expanded(
                          child: Obx(() {
                            return ApiStateView(
                              state: _lessonsState,
                              errorMessage: controller.error.value,
                              emptyMessage: T.emptyGrammarLessons.tr,
                              onRetry: () {
                                final topic = controller.selectedTopic.value;
                                if (topic != null) {
                                  controller.loadLessons(topic.id);
                                }
                              },
                              builder: (_) => ListView.separated(
                                itemCount: controller.lessons.length,
                                separatorBuilder: (_, __) => AppGap.h10,
                                itemBuilder: (_, index) {
                                  final lesson = controller.lessons[index];
                                  return _LessonTile(lesson: lesson);
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});

  final GrammarLessonListItem lesson;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => Get.toNamed(
        AppRoutes.grammarLessonDetail,
        arguments: lesson.id,
      ),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                '${lesson.sortOrder}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
            AppGap.w10,
            Expanded(
              child: Text(
                lesson.title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}
