import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// Khối cá nhân hóa trên Home:
///   P5 — banner "thẻ cần ôn hôm nay" (số thẻ SM-2 tới hạn của user).
///   P3 — banner "Tiếp tục / Làm lại" bài học dở dang theo tiến độ thật.
/// Ẩn từng banner khi không có dữ liệu cá nhân hóa (giữ Home gọn cho user mới).
class HomePersonalizedSection extends GetView<HomeController> {
  const HomePersonalizedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.dashboard.value; // theo dõi thay đổi dashboard
      final due = controller.dueCardCount;
      final cl = controller.continueLearning;
      final showContinue =
          cl != null && cl.type == 'lesson' && (cl.title ?? '').isNotEmpty;

      if (due <= 0 && !showContinue) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (due > 0) ...[
              _DueCardsBanner(count: due, onTap: controller.onReviewDueCards),
              if (showContinue) AppGap.h12,
            ],
            if (showContinue)
              _ContinueLessonBanner(
                title: cl.title!,
                level: cl.level ?? '',
                isRetry: cl.isRetry,
                progress: cl.progress,
                onTap: controller.onContinueLearning,
              ),
          ],
        ),
      );
    });
  }
}

/// P5 — số thẻ flashcard tới hạn ôn (nối thẳng SM-2 spaced repetition).
class _DueCardsBanner extends StatelessWidget {
  const _DueCardsBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.statBgWarm,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.refresh_rounded, color: AppColors.statFgWarm, size: 24),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn có $count thẻ cần ôn hôm nay',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ôn đúng lúc giúp nhớ lâu hơn (spaced repetition)',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.statFgWarm),
            ],
          ),
        ),
      ),
    );
  }
}

/// P3 — bài học dở dang theo tiến độ thật (Tiếp tục / Làm lại).
class _ContinueLessonBanner extends StatelessWidget {
  const _ContinueLessonBanner({
    required this.title,
    required this.level,
    required this.isRetry,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String level;
  final bool isRetry;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = isRetry ? AppColors.tertiary : AppColors.primary;
    final IconData icon =
        isRetry ? Icons.replay_rounded : Icons.play_circle_fill_rounded;
    final String tag = isRetry ? 'Làm lại' : 'Đang học dở';

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 26),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                        if (level.isNotEmpty) ...[
                          AppGap.w8,
                          Text(
                            level,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
