import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/home/models/home_dashboard_model.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeRecommendations extends GetView<HomeController> {
  const HomeRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recommendations;
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Gợi ý cho cấp độ ${controller.userLevel}',
              style: AppTypography.displayLarge.copyWith(fontSize: 17),
            ),
          ),
          AppGap.h12,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildGrid(items),
          ),
        ],
      );
    });
  }

  Widget _buildGrid(List<HomeRecommendation> items) {
    if (items.length == 1) {
      return _RecommendCard(
        item: items[0],
        onTap: () => controller.onRecommendTap(items[0]),
      );
    }

    final rows = <Widget>[];
    // Card đầu tiên full width
    rows.add(
      _RecommendCard(
        item: items[0],
        onTap: () => controller.onRecommendTap(items[0]),
      ),
    );

    // Các card còn lại ghép theo cặp
    for (int i = 1; i < items.length; i += 2) {
      rows.add(AppGap.h12);
      if (i + 1 < items.length) {
        rows.add(
          Row(
            children: [
              Expanded(
                child: _RecommendCard(
                  item: items[i],
                  onTap: () => controller.onRecommendTap(items[i]),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: _RecommendCard(
                  item: items[i + 1],
                  onTap: () => controller.onRecommendTap(items[i + 1]),
                ),
              ),
            ],
          ),
        );
      } else {
        rows.add(
          _RecommendCard(
            item: items[i],
            onTap: () => controller.onRecommendTap(items[i]),
          ),
        );
      }
    }

    return Column(children: rows);
  }
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({required this.item, required this.onTap});

  final HomeRecommendation item;
  final VoidCallback onTap;

  static IconData _iconFor(String type) => switch (type) {
    'vocabulary' => Icons.psychology_rounded,
    'grammar' => Icons.menu_book_rounded,
    'exercise' => Icons.quiz_rounded,
    'pronunciation' => Icons.mic_rounded,
    'flashcard' => Icons.style_rounded,
    'test' => Icons.assignment_rounded,
    _ => Icons.star_rounded,
  };

  bool get _isOrange => item.type == 'pronunciation';

  @override
  Widget build(BuildContext context) {
    final Color iconColor = _isOrange ? AppColors.tertiary : AppColors.primary;
    final Color bgColor = _isOrange
        ? AppColors.recommendationOrangeBg
        : AppColors.recommendationMutedBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(item.type), color: iconColor, size: 28),
            const SizedBox(height: 28),
            Text(
              item.title,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isOrange ? AppColors.onSurface : AppColors.primary,
              ),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.description,
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
