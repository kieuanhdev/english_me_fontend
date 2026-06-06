import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/grammar/controllers/grammar_theory_controller.dart';
import 'package:englishme/modules/grammar/models/grammar_models.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Read-only grammar theory library, organized as one tab per CEFR level.
/// Separate from the practice-oriented [GrammarScreen]: here the user browses
/// ALL theory by level and reads lessons with exercises hidden.
class GrammarTheoryScreen extends GetView<GrammarTheoryController> {
  const GrammarTheoryScreen({super.key});

  static const _levels = GrammarTheoryController.cefrLevels;

  ApiState get _state {
    if (controller.isLoading.value) return ApiState.loading;
    if (controller.error.value.isNotEmpty && controller.groups.isEmpty) {
      return ApiState.error;
    }
    return ApiState.success;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _levels.length,
      initialIndex: controller.initialTabIndex.value,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        bottomNavigationBar: AppBottomNav(
          initialIndex: 2,
          onTap: (index, _) => ShellController.goToTab(index),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: AppMainAppBar(
                  title: T.titleGrammarTheory.tr,
                  showBack: true,
                  showSettings: false,
                  showNotification: false,
                  horizontalPadding: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  T.descGrammarTheory.tr,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                tabs: _levels.map((lv) => Tab(text: lv)).toList(),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(
                  () => ApiStateView(
                    state: _state,
                    errorMessage: controller.error.value,
                    onRetry: controller.loadGroups,
                    builder: (_) => TabBarView(
                      children: _levels
                          .map((lv) => _LevelTopicList(level: lv))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Maps a CEFR level (A1..C2) to the theme's coarse A/B/C color tier.
class _LevelColors {
  const _LevelColors(this.bg, this.fg);
  final Color bg;
  final Color fg;

  factory _LevelColors.of(String level) {
    final tier = level.isEmpty ? 'A' : level[0].toUpperCase();
    switch (tier) {
      case 'C':
        return _LevelColors(AppColors.levelCBg, AppColors.levelCFg);
      case 'B':
        return _LevelColors(AppColors.levelBBg, AppColors.levelBFg);
      default:
        return _LevelColors(AppColors.levelABg, AppColors.levelAFg);
    }
  }
}

class _LevelTopicList extends GetView<GrammarTheoryController> {
  const _LevelTopicList({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final topics = controller.topicsForLevel(level);
      if (topics.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              T.emptyGrammarTheoryLevel.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: topics.length,
        separatorBuilder: (_, __) => AppGap.h10,
        itemBuilder: (_, index) =>
            _TopicCard(topic: topics[index], level: level),
      );
    });
  }
}

class _TopicCard extends GetView<GrammarTheoryController> {
  const _TopicCard({required this.topic, required this.level});

  final GrammarTopic topic;
  final String level;

  @override
  Widget build(BuildContext context) {
    final colors = _LevelColors.of(level);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Strip the default ExpansionTile divider lines.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          onExpansionChanged: (open) {
            if (open) controller.loadLessonsForTopic(topic.id);
          },
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              topic.level,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: colors.fg,
              ),
            ),
          ),
          title: Text(
            topic.title,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${topic.category} • ${topic.lessonCount} ${T.labelLessons.tr.toLowerCase()}',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            Obx(() {
              final lessons = controller.lessonsByTopic[topic.id];
              final loading = controller.loadingTopicIds.contains(topic.id);
              if (loading && lessons == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (lessons == null) return const SizedBox.shrink();
              if (lessons.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    T.emptyGrammarLessons.tr,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return Column(
                children: lessons
                    .map((l) => _LessonRow(lesson: l))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson});

  final GrammarLessonListItem lesson;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () => Get.toNamed(
        AppRoutes.grammarLessonDetail,
        arguments: {'lessonId': lesson.id, 'theoryOnly': true},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            AppGap.w10,
            Expanded(
              child: Text(
                lesson.title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
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
