import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/data/models/grammar_models.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/grammar/controllers/grammar_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GrammarScreen extends GetView<GrammarController> {
  const GrammarScreen({super.key});

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
              const AppMainAppBar(title: 'Ngữ pháp'),
              AppGap.h20,
              Text(
                'Chủ đề ngữ pháp',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                ),
              ),
              AppGap.h8,
              Text(
                'Chọn một chủ đề để xem danh sách bài học từ API backend.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppGap.h12,
              GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.grammarLessonDetail,
                  arguments: '__mock__',
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Xem demo bài tập (mock data)',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppGap.h16,
              Obx(() {
                if (controller.isLoadingTopics.value) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.error.value.isNotEmpty &&
                    controller.topics.isEmpty) {
                  return Expanded(
                    child: _StateMessage(
                      text: controller.error.value,
                      onRetry: controller.loadTopics,
                    ),
                  );
                }
                if (controller.topics.isEmpty) {
                  return const Expanded(
                    child: _StateMessage(text: 'Chưa có chủ đề ngữ pháp nào.'),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
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
                        ),
                      ),
                      AppGap.h16,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Obx(() {
                          final topic = controller.selectedTopic.value;
                          return Text(
                            topic == null
                                ? 'Bài học'
                                : '${topic.title} (${topic.lessonCount} bài)',
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
                          if (controller.isLoadingLessons.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (controller.error.value.isNotEmpty &&
                              controller.lessons.isEmpty) {
                            return _StateMessage(
                              text: controller.error.value,
                              onRetry: () {
                                final topic = controller.selectedTopic.value;
                                if (topic != null) {
                                  controller.loadLessons(topic.id);
                                }
                              },
                            );
                          }
                          if (controller.lessons.isEmpty) {
                            return const _StateMessage(
                              text: 'Chủ đề này chưa có bài học.',
                            );
                          }

                          return ListView.separated(
                            itemCount: controller.lessons.length,
                            separatorBuilder: (_, __) => AppGap.h10,
                            itemBuilder: (_, index) {
                              final lesson = controller.lessons[index];
                              return _LessonTile(lesson: lesson);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }),
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
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
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
      borderRadius: BorderRadius.circular(14),
      onTap: () => Get.toNamed(
        AppRoutes.grammarLessonDetail,
        arguments: lesson.id,
      ),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
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

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            AppGap.h10,
            FilledButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ],
      ),
    );
  }
}
