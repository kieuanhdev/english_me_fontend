import 'package:flutter/material.dart' hide Badge;
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/profile/models/profile_model.dart';
import 'package:englishme/theme/app_theme.dart';

class AchievementSection extends StatelessWidget {
  const AchievementSection({super.key, required this.badges});
  final List<Badge> badges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.tertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Thành tích',
              style: AppTypography.headlineMedium.copyWith(fontSize: 16),
            ),
            const Spacer(),
            Text(
              '${badges.where((b) => b.unlocked).length}/${badges.length}',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        AppGap.h12,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (_, i) => _BadgeCard(badge: badges[i]),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(
              fontSize: 30,
              color: unlocked ? null : Colors.transparent,
            ),
          ),
          AppGap.h6,
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.onSurface : AppColors.textSecondary,
            ),
          ),
          if (!unlocked) ...[
            const SizedBox(height: 4),
            Icon(Icons.lock_rounded, size: 12, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}
