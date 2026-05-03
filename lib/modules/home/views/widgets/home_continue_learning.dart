import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeContinueLearning extends GetView<HomeController> {
  const HomeContinueLearning({super.key});

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.neutralShadow,
                    offset: Offset(0, 3),
                    blurRadius: 8,
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LessonThumbnail(),
                  _LessonInfo(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      color: AppColors.secondaryContainer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder gradient thay ảnh thực
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.travel_explore_rounded,
              size: 64,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonInfo extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            controller.lessonLevel.value,
            style: AppTypography.labelMedium.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.tertiary,
            ),
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            controller.lessonTitle.value,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 22,
              color: AppColors.primary,
            ),
          )),
          const SizedBox(height: 10),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bài ${controller.lessonCurrent.value}/${controller.lessonTotal.value}',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(controller.lessonProgress.value * 100).toInt()}%',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          )),
          const SizedBox(height: 6),
          Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: controller.lessonProgress.value,
                backgroundColor: AppColors.secondaryContainer,
                valueColor: const AlwaysStoppedAnimation(AppColors.tertiary),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
