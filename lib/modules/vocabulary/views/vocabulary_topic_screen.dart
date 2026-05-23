import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/vocabulary/controllers/vocabulary_controller.dart';
import 'package:englishme/modules/vocabulary/models/vocabulary_model.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabularyTopicScreen extends GetView<VocabularyController> {
  const VocabularyTopicScreen({super.key});

  ApiState _mapState(VocabScreenState s, VocabularyController c) {
    switch (s) {
      case VocabScreenState.idle:
      case VocabScreenState.loading:
        return ApiState.loading;
      case VocabScreenState.error:
        return ApiState.error;
      case VocabScreenState.loaded:
        return c.topics.isEmpty ? ApiState.empty : ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppMainAppBar(
                    title: T.titleVocabulary.tr,
                    horizontalPadding: 0,
                  ),
                  AppGap.h6,
                  Text(
                    T.descVocabByTopic.tr,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h16,
            Expanded(
              child: Obx(() {
                return ApiStateView(
                  state: _mapState(controller.topicsState.value, controller),
                  errorMessage: T.errorLoadVocabTopics.tr,
                  emptyMessage: T.emptyVocabTopics.tr,
                  emptyIcon: Icons.menu_book_outlined,
                  onRetry: controller.loadTopics,
                  builder: (_) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    itemCount: controller.topics.length,
                    separatorBuilder: (_, _) => AppGap.h12,
                    itemBuilder: (_, i) =>
                        _TopicCard(topic: controller.topics[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Topic Card ───────────────────────────────────────────────────────────────

class _TopicCard extends GetView<VocabularyController> {
  const _TopicCard({required this.topic});
  final VocabularyTopic topic;

  Color get _color => _hexToColor(topic.colorHex);

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.openTopic(topic),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(color: AppColors.shadowSoft, blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(topic.icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.nameEn,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(
                        label: T.labelWordCount.tr.replaceAll('{count}', '${topic.wordCount}'),
                        icon: Icons.style_rounded,
                        color: _color,
                      ),
                      AppGap.w8,
                      _Chip(
                        label: controller.levelLabel(topic.level),
                        icon: Icons.bar_chart_rounded,
                        color: controller.levelColor(topic.level),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelXSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
