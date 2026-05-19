import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeContinueLearning extends GetView<HomeController> {
  const HomeContinueLearning({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cl = controller.continueLearning;
      if (cl == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tiếp tục học tập',
                  style: AppTypography.displayLarge.copyWith(fontSize: 17),
                ),
                GestureDetector(
                  onTap: controller.onSeeAllLessons,
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.h12,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: controller.onContinueLearning,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
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
                    const _LessonThumbnail(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CẤP ĐỘ ${(cl.level ?? '').toUpperCase()}',
                            style: AppTypography.labelMedium.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: AppColors.tertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cl.title ?? 'Tiếp tục học',
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 22,
                              color: AppColors.primary,
                            ),
                          ),
                          if (cl.type != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _typeLabel(cl.type!),
                              style: AppTypography.bodyLarge.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
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
        return type;
    }
  }
}

class _LessonThumbnail extends StatelessWidget {
  const _LessonThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      color: AppColors.secondaryContainer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.travel_explore_rounded,
              size: 64,
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.54),
            ),
          ),
        ],
      ),
    );
  }
}
