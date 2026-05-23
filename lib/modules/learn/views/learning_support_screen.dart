import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/learn/controllers/learning_controller.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/theme/app_theme.dart';

class LearningSupportScreen extends GetView<LearningController> {
  const LearningSupportScreen({super.key});

  ApiState get _state {
    return switch (controller.hubState.value) {
      LearningHubState.idle || LearningHubState.loading => ApiState.loading,
      LearningHubState.error => ApiState.error,
      LearningHubState.loaded =>
        controller.hub.value == null ? ApiState.empty : ApiState.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _state,
            errorMessage: controller.errorMessage.value,
            emptyMessage: 'Chưa có học phần bổ trợ.',
            onRetry: () =>
                controller.loadHub(level: controller.selectedLevel.value),
            builder: (_) {
              final hub = controller.hub.value!;
              return RefreshIndicator(
                onRefresh: () => controller.loadHub(level: hub.selectedLevel),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppMainAppBar(
                        title: 'Học phần bổ trợ',
                        horizontalPadding: 0,
                      ),
                      AppGap.h8,
                      Text(
                        'Ngữ pháp, từ vựng và flashcard hỗ trợ trực tiếp cho quá trình học.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      AppGap.h20,
                      if (hub.supportTracks.isEmpty)
                        const _EmptySupportState()
                      else
                        ...hub.supportTracks.map(
                          (track) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SupportTile(
                              track: track,
                              onTap: () => controller.openSupport(track),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.track, required this.onTap});

  final LearningSupportTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _supportColor(track.type);
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: track.enabled ? onTap : null,
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
                child: Icon(_supportIcon(track.type), color: color, size: 23),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      track.description,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySupportState extends StatelessWidget {
  const _EmptySupportState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        'Chưa có học phần bổ trợ cho cấp độ này.',
        style: AppTypography.bodySmall,
      ),
    );
  }
}

IconData _supportIcon(String type) {
  return switch (type) {
    'grammar' => Icons.menu_book_rounded,
    'vocabulary' => Icons.style_rounded,
    'flashcard' => Icons.layers_rounded,
    'test' => Icons.assignment_turned_in_rounded,
    _ => Icons.extension_rounded,
  };
}

Color _supportColor(String type) {
  return switch (type) {
    'grammar' => AppColors.skillGrammar,
    'vocabulary' => AppColors.skillVocabulary,
    'flashcard' => AppColors.tertiary,
    'test' => AppColors.primary,
    _ => AppColors.primary,
  };
}
