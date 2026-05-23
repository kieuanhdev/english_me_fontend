import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/home/models/home_dashboard_model.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeContinueLearning extends GetView<HomeController> {
  const HomeContinueLearning({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final path = controller.currentLearningPath;
      final fallback = controller.continueLearning;
      if (path == null && fallback == null) return const SizedBox.shrink();

      final viewData = _ContinueLearningViewData.from(path, fallback);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Path đang học',
                  style: AppTypography.displayLarge.copyWith(fontSize: 17),
                ),
                GestureDetector(
                  onTap: controller.onSeeAllLessons,
                  child: Text(
                    'Xem lộ trình',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h12,
            Material(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: InkWell(
                onTap: controller.onContinueLearning,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neutralShadow,
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PathThumbnail(level: viewData.level),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _LevelPill(level: viewData.level),
                                const Spacer(),
                                if (viewData.activityCount > 0)
                                  Text(
                                    '${viewData.completedActivityCount}/${viewData.activityCount} hoạt động',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                            AppGap.h10,
                            Text(
                              viewData.title,
                              style: AppTypography.displayLarge.copyWith(
                                fontSize: 21,
                                color: AppColors.primary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (viewData.description.isNotEmpty) ...[
                              AppGap.h6,
                              Text(
                                viewData.description,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            AppGap.h14,
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: LinearProgressIndicator(
                                value: viewData.progress,
                                minHeight: 7,
                                backgroundColor: AppColors.progressTrack,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            AppGap.h12,
                            Row(
                              children: [
                                Text(
                                  '${(viewData.progress * 100).round()}% hoàn thành',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Học ngay',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.onPrimaryFixed,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.play_arrow_rounded,
                                        size: 16,
                                        color: AppColors.onPrimaryFixed,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ContinueLearningViewData {
  const _ContinueLearningViewData({
    required this.title,
    required this.description,
    required this.level,
    required this.progress,
    required this.activityCount,
    required this.completedActivityCount,
  });

  final String title;
  final String description;
  final String level;
  final double progress;
  final int activityCount;
  final int completedActivityCount;

  factory _ContinueLearningViewData.from(
    LearningPath? path,
    ContinueLearning? fallback,
  ) {
    if (path != null) {
      return _ContinueLearningViewData(
        title: path.title,
        description: path.description,
        level: path.level,
        progress: path.progress,
        activityCount: path.activityCount,
        completedActivityCount: path.completedActivityCount,
      );
    }
    return _ContinueLearningViewData(
      title: fallback?.title ?? 'Tiếp tục lộ trình học',
      description:
          fallback?.description ?? _typeLabel(fallback?.type ?? 'learning'),
      level: fallback?.level ?? '',
      progress: fallback?.progress ?? 0,
      activityCount: fallback?.activityCount ?? 0,
      completedActivityCount: fallback?.completedActivityCount ?? 0,
    );
  }
}

class _PathThumbnail extends StatelessWidget {
  const _PathThumbnail({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF43A047)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Icon(
              Icons.route_rounded,
              size: 132,
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Icon(
                Icons.school_rounded,
                size: 42,
                color: AppColors.onPrimaryFixed.withValues(alpha: 0.86),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final text = level.trim().isEmpty ? 'CEFR' : level.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.tertiary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'vocabulary':
      return 'Từ vựng';
    case 'grammar':
      return 'Ngữ pháp';
    case 'pronunciation':
      return 'Phát âm';
    case 'flashcard':
      return 'Flashcard';
    default:
      return 'Lộ trình học tập';
  }
}
