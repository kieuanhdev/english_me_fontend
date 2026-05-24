import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_topic_controller.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_level.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_topic_model.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabTopicListScreen extends GetView<VocabTopicController> {
  const VocabTopicListScreen({super.key, this.embedded = false});

  /// true khi dùng bên trong TabBarView (không cần Scaffold/AppBar riêng)
  final bool embedded;

  ApiState _mapState() {
    switch (controller.topicsState.value) {
      case VocabLoadState.idle:
      case VocabLoadState.loading:
        return ApiState.loading;
      case VocabLoadState.error:
        return ApiState.error;
      case VocabLoadState.loaded:
        return controller.topics.isEmpty ? ApiState.empty : ApiState.success;
    }
  }

  Widget _body() => Obx(() {
        return ApiStateView(
          state: _mapState(),
          errorMessage: 'Không tải được danh sách chủ đề',
          emptyMessage: 'Chưa có chủ đề nào',
          emptyIcon: Icons.menu_book_outlined,
          onRetry: controller.loadTopics,
          builder: (_) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            itemCount: controller.topics.length,
            separatorBuilder: (_, __) => AppGap.h12,
            itemBuilder: (_, i) => _TopicCard(topic: controller.topics[i]),
          ),
        );
      });

  @override
  Widget build(BuildContext context) {
    if (embedded) return _body();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(child: _body()),
    );
  }
}

// ─── Topic Card ───────────────────────────────────────────────────────────────

class _TopicCard extends GetView<VocabTopicController> {
  const _TopicCard({required this.topic});
  final VocabTopic topic;

  Color get _color {
    final h = topic.colorHex.replaceAll('#', '');
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
              child: Center(child: Text(topic.icon, style: const TextStyle(fontSize: 26))),
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
                        label: '${topic.wordCount} từ',
                        icon: Icons.style_rounded,
                        color: _color,
                      ),
                      AppGap.w8,
                      _Chip(
                        label: topic.level.label,
                        icon: Icons.bar_chart_rounded,
                        color: _levelColor(topic.level),
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

  Color _levelColor(VocabLevel level) => switch (level) {
        VocabLevel.a1 => const Color(0xFF4CAF50),
        VocabLevel.a2 => const Color(0xFF8BC34A),
        VocabLevel.b1 => const Color(0xFF2196F3),
        VocabLevel.b2 => const Color(0xFF9C27B0),
        VocabLevel.c1 => const Color(0xFFFF9800),
        VocabLevel.c2 => const Color(0xFFF44336),
      };
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
