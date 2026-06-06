import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/theme/app_theme.dart';

/// Lối vào giáo trình học theo Unit (thay cho "Path đang học" cũ).
/// Hiện Unit đang học nếu có; nếu chưa, hiện banner "Học theo Unit" chung.
class HomeContinueLearning extends GetView<HomeController> {
  const HomeContinueLearning({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Lộ trình của bạn',
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
          Obx(() {
            // Đang tải → khung chờ, tránh nhảy banner chung (sai) rồi mới đổi.
            if (controller.currentUnitLoading.value) {
              return const _UnitCardSkeleton();
            }
            final unit = controller.currentUnit.value;
            return unit == null
                ? _GenericEntryCard(
                    level: controller.homeLevel,
                    onTap: controller.onContinueLearning,
                  )
                : _UnitProgressCard(
                    unit: unit,
                    onTap: () => controller.openUnitFromHome(unit),
                  );
          }),
        ],
      ),
    );
  }
}

/// Card Unit đang học — tên Unit, tiến độ x/y bài, nút Học tiếp.
class _UnitProgressCard extends StatelessWidget {
  const _UnitProgressCard({required this.unit, required this.onTap});

  final CurriculumUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryShadow,
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: -16,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 128,
                  color: AppColors.onPrimaryFixed.withValues(alpha: 0.14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Pill(text: unit.level),
                        AppGap.w8,
                        _Pill(
                          text: unit.isCompleted ? 'Hoàn thành' : 'Đang học',
                        ),
                        const Spacer(),
                        Text(
                          '${unit.completedLessonCount}/${unit.lessonCount} bài',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onPrimaryFixed
                                .withValues(alpha: 0.92),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    AppGap.h12,
                    Text(
                      'Unit ${unit.order}: ${unit.title}',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 20,
                        color: AppColors.onPrimaryFixed,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (unit.subtitle.isNotEmpty) ...[
                      AppGap.h6,
                      Text(
                        unit.subtitle,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 13,
                          color:
                              AppColors.onPrimaryFixed.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    AppGap.h14,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: unit.progress,
                        minHeight: 7,
                        backgroundColor:
                            AppColors.onPrimaryFixed.withValues(alpha: 0.24),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimaryFixed,
                        ),
                      ),
                    ),
                    AppGap.h12,
                    Row(
                      children: [
                        Text(
                          '${(unit.progress * 100).round()}% hoàn thành',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onPrimaryFixed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.onPrimaryFixed,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                unit.completedLessonCount > 0
                                    ? 'Học tiếp'
                                    : 'Bắt đầu',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 16,
                                color: AppColors.primary,
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
    );
  }
}

/// Banner chung khi chưa xác định được Unit đang học.
class _GenericEntryCard extends StatelessWidget {
  const _GenericEntryCard({required this.level, required this.onTap});

  final String level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryShadow,
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: -16,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 128,
                  color: AppColors.onPrimaryFixed.withValues(alpha: 0.14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Pill(text: level),
                    AppGap.h12,
                    Text(
                      'Học theo Unit',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 22,
                        color: AppColors.onPrimaryFixed,
                      ),
                    ),
                    AppGap.h6,
                    Text(
                      'Lý thuyết → Bài tập → Quiz, lên cấp khi hoàn thành từng Unit.',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 13,
                        color:
                            AppColors.onPrimaryFixed.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimaryFixed,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Học ngay',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Khung chờ khi đang tải Unit đang học — giữ kích thước tương đương card thật
/// để layout không nhảy, dùng các dải xám trung tính làm placeholder.
class _UnitCardSkeleton extends StatelessWidget {
  const _UnitCardSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              bar(44, 22),
              AppGap.w8,
              bar(64, 22),
              const Spacer(),
              bar(48, 16),
            ],
          ),
          AppGap.h14,
          bar(double.infinity, 20),
          AppGap.h8,
          bar(180, 14),
          AppGap.h16,
          bar(double.infinity, 7),
          AppGap.h14,
          Row(
            children: [
              bar(96, 14),
              const Spacer(),
              bar(92, 34),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final label = text.trim().isEmpty ? 'CEFR' : text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.onPrimaryFixed.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.onPrimaryFixed,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
