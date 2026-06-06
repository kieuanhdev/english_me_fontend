import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/learn/controllers/unit_list_controller.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class UnitListScreen extends GetView<UnitListController> {
  const UnitListScreen({super.key});

  ApiState _stateOf() {
    if (controller.loading.value) return ApiState.loading;
    if (controller.error.value.isNotEmpty) return ApiState.error;
    return controller.data.value == null ? ApiState.empty : ApiState.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(() {
            return ApiStateView(
              state: _stateOf(),
              errorMessage: 'Không tải được danh sách Unit.',
              emptyMessage: 'Cấp độ này chưa có Unit nào.',
              onRetry: controller.load,
              builder: (_) {
                final d = controller.data.value!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppBackButton(onPressed: Get.back),
                        AppGap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giáo trình ${d.level}',
                                style: AppTypography.displayLarge.copyWith(
                                  fontSize: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                              AppGap.h2,
                              Text(
                                '${d.completedUnits}/${d.totalUnits} Unit hoàn thành',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppGap.h16,
                    _LevelOverview(
                      data: d,
                      onCheckpoint: () async {
                        await Get.toNamed(
                          AppRoutes.curriculumCheckpoint,
                          arguments: {'level': d.level},
                        );
                        controller.load(); // refresh (có thể đã lên cấp)
                      },
                    ),
                    AppGap.h16,
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: d.units.length,
                        separatorBuilder: (_, __) => AppGap.h10,
                        itemBuilder: (_, index) => _UnitCard(
                          unit: d.units[index],
                          onTap: () => controller.openUnit(d.units[index]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _LevelOverview extends StatelessWidget {
  const _LevelOverview({required this.data, required this.onCheckpoint});
  final LevelUnits data;
  final VoidCallback onCheckpoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow,
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tiến độ cấp ${data.level}',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.onPrimaryFixed,
                    fontSize: 18,
                  ),
                ),
              ),
              if (data.checkpointUnlocked)
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: onCheckpoint,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimaryFixed.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lên cấp!',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onPrimaryFixed,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.onPrimaryFixed),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          AppGap.h16,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: data.levelProgress,
              minHeight: 8,
              backgroundColor: AppColors.onPrimaryFixed.withValues(alpha: 0.22),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.tertiaryFixedDim),
            ),
          ),
          AppGap.h8,
          Text(
            '${(data.levelProgress * 100).round()}% hoàn thành cấp độ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, required this.onTap});
  final CurriculumUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = unit.isLocked;
    final Color color = disabled ? AppColors.iconMuted : AppColors.primary;
    final IconData icon = unit.isCompleted
        ? Icons.check_rounded
        : disabled
            ? Icons.lock_rounded
            : Icons.play_arrow_rounded;

    return Material(
      color: disabled
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, color: color, size: 23),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.order}. ${unit.title}',
                          style: AppTypography.bodyRegular.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppGap.h2,
                        Text(
                          unit.subtitle,
                          style: AppTypography.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppGap.w8,
                  Icon(
                    unit.isCompleted
                        ? Icons.check_circle_rounded
                        : disabled
                            ? Icons.lock_rounded
                            : Icons.chevron_right_rounded,
                    color: unit.isCompleted
                        ? AppColors.success
                        : AppColors.iconMuted,
                  ),
                ],
              ),
              if (unit.skillCoverage.isNotEmpty) ...[
                AppGap.h10,
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: unit.skillCoverage
                      .map((s) => _SkillPill(skill: s))
                      .toList(growable: false),
                ),
              ],
              AppGap.h12,
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: unit.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.progressTrack,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  AppGap.w10,
                  Text(
                    '${unit.completedLessonCount}/${unit.lessonCount} bài',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.skill});
  final String skill;

  @override
  Widget build(BuildContext context) {
    final color = skillColor(skill);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        skillLabel(skill),
        style: AppTypography.labelXSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ── Helpers dùng chung cho UI giáo trình (đồng nhất với learn cũ) ──
String skillLabel(String skill) => switch (skill) {
      'listening' => 'Nghe',
      'speaking' => 'Nói',
      'reading' => 'Đọc',
      'writing' => 'Viết',
      'grammar' => 'Ngữ pháp',
      'vocabulary' => 'Từ vựng',
      _ => skill,
    };

Color skillColor(String skill) => switch (skill) {
      'listening' => AppColors.skillListening,
      'speaking' => AppColors.tertiary,
      'reading' => AppColors.success,
      'writing' => AppColors.primary,
      'grammar' => AppColors.skillGrammar,
      'vocabulary' => AppColors.skillVocabulary,
      _ => AppColors.primary,
    };

IconData skillIcon(String skill) => switch (skill) {
      'listening' => Icons.headphones_rounded,
      'speaking' => Icons.record_voice_over_rounded,
      'reading' => Icons.article_rounded,
      'writing' => Icons.edit_note_rounded,
      'grammar' => Icons.menu_book_rounded,
      'vocabulary' => Icons.style_rounded,
      _ => Icons.school_rounded,
    };
