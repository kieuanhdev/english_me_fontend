import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// H1 — Khối "Dành riêng cho bạn" trên Home: GOM các tín hiệu cá nhân hóa rời rạc
/// (SM-2 due cards, bài đang học dở/làm lại, kỹ năng yếu nhất) vào 1 section có
/// tiêu đề gọi tên rõ ràng + dòng lý do "vì sao hiện với BẠN" (H2), thay vì để
/// các banner trôi nổi không ai biết đó là cá nhân hóa.
///
/// Ẩn cả section khi user mới chưa có tín hiệu nào (giữ Home gọn).
class HomePersonalizedSection extends GetView<HomeController> {
  const HomePersonalizedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.dashboard.value; // theo dõi thay đổi dashboard
      controller.skillBreakdown.value; // theo dõi thay đổi per-skill
      final due = controller.dueCardCount;
      final cl = controller.continueLearning;
      final showContinue =
          cl != null && cl.type == 'lesson' && (cl.title ?? '').isNotEmpty;
      final weakLabel = controller.weakestSkillLabel;
      final showWeak = weakLabel.isNotEmpty;

      if (due <= 0 && !showContinue && !showWeak) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(),
            AppGap.h12,
            if (due > 0) ...[
              _PersonalCard(
                icon: Icons.refresh_rounded,
                bg: AppColors.statBgWarm,
                accent: AppColors.statFgWarm,
                title: 'Bạn có $due thẻ cần ôn hôm nay',
                reason: 'Đến hạn theo lịch ôn cá nhân (spaced repetition) — '
                    'ôn đúng lúc giúp nhớ lâu hơn',
                onTap: controller.onReviewDueCards,
              ),
              if (showContinue || showWeak) AppGap.h12,
            ],
            if (showContinue) ...[
              _ContinueCard(
                title: cl.title!,
                level: cl.level ?? '',
                isRetry: cl.isRetry,
                lastScore: (cl.progress * 100).round(),
                onTap: controller.onContinueLearning,
              ),
              if (showWeak) AppGap.h12,
            ],
            if (showWeak)
              _PersonalCard(
                icon: Icons.trending_up_rounded,
                bg: AppColors.tertiary.withValues(alpha: 0.10),
                accent: AppColors.tertiary,
                title: 'Tập trung vào $weakLabel',
                reason: controller.weakestSkillReason,
                onTap: controller.onPracticeWeakestSkill,
              ),
          ],
        ),
      );
    });
  }
}

/// Tiêu đề section + dòng phụ gọi tên cá nhân hóa.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(Icons.auto_awesome_rounded,
              size: 20, color: AppColors.primary),
        ),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dành riêng cho bạn',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Dựa trên cách bạn học',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card cá nhân hóa chung: icon + tiêu đề + 1 dòng lý do (vì sao hiện với BẠN).
class _PersonalCard extends StatelessWidget {
  const _PersonalCard({
    required this.icon,
    required this.bg,
    required this.accent,
    required this.title,
    required this.reason,
    required this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color accent;
  final String title;
  final String reason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 24),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
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

/// Bài học dở dang theo tiến độ thật (Tiếp tục / Làm lại) — kèm lý do.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.title,
    required this.level,
    required this.isRetry,
    required this.lastScore,
    required this.onTap,
  });

  final String title;
  final String level;
  final bool isRetry;
  final int lastScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = isRetry ? AppColors.tertiary : AppColors.primary;
    final IconData icon =
        isRetry ? Icons.replay_rounded : Icons.play_circle_fill_rounded;
    final String tag = isRetry ? 'Làm lại' : 'Đang học dở';
    final String reason = isRetry
        ? 'Lần trước đạt $lastScore điểm — chưa đạt ngưỡng, thử lại nhé'
        : 'Bạn đang học dở bài này — tiếp tục để hoàn thành';

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
                    const SizedBox(height: 2),
                    Text(
                      reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
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
