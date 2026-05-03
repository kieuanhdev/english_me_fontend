import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeRecommendations extends GetView<HomeController> {
  const HomeRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() => Text(
            'Gợi ý cho cấp độ ${controller.userLevel.value}',
            style: AppTypography.displayLarge.copyWith(fontSize: 17),
          )),
        ),
        AppGap.h12,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            final items = controller.recommendations;
            return Column(
              children: [
                // Row 1: wide card full width
                _RecommendCard(
                  item: items[0],
                  onTap: () => controller.onRecommendTap(items[0]),
                ),
                AppGap.h12,
                // Row 2: two small cards side by side
                Row(
                  children: [
                    Expanded(
                      child: _RecommendCard(
                        item: items[1],
                        onTap: () => controller.onRecommendTap(items[1]),
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: _RecommendCard(
                        item: items[2],
                        onTap: () => controller.onRecommendTap(items[2]),
                      ),
                    ),
                  ],
                ),
                AppGap.h12,
                // Row 3: AI chat card full width horizontal
                _RecommendCardHorizontal(
                  item: items[3],
                  onTap: () => controller.onRecommendTap(items[3]),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({required this.item, required this.onTap});

  final RecommendItem item;
  final VoidCallback onTap;

  static IconData _iconFor(String name) => switch (name) {
    'psychology' => Icons.psychology_rounded,
    'quiz' => Icons.quiz_rounded,
    'mic' => Icons.mic_rounded,
    'smart_toy' => Icons.smart_toy_rounded,
    _ => Icons.star_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        item.isOrange ? AppColors.tertiary : AppColors.primary;
    final Color bgColor =
        item.isOrange ? const Color(0xFFFFF3E0) : AppColors.surfaceContainerLow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(item.icon), color: iconColor, size: 28),
            const SizedBox(height: 28),
            Text(
              item.title,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: item.isOrange ? AppColors.onSurface : AppColors.primary,
              ),
            ),
            if (item.subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendCardHorizontal extends StatelessWidget {
  const _RecommendCardHorizontal({required this.item, required this.onTap});

  final RecommendItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.iconMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
