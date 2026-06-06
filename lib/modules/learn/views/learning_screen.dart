import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/learn/controllers/learning_controller.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class LearningScreen extends GetView<LearningController> {
  const LearningScreen({super.key});

  ApiState get _state {
    return switch (controller.hubState.value) {
      LearningHubState.idle || LearningHubState.loading => ApiState.loading,
      LearningHubState.error => ApiState.error,
      LearningHubState.loaded =>
        controller.hub.value == null ? ApiState.empty : ApiState.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _state,
            errorMessage: controller.errorMessage.value,
            emptyMessage: 'Chưa có lộ trình học tập.',
            onRetry: () =>
                controller.loadHub(level: controller.selectedLevel.value),
            builder: (_) {
              final hub = controller.hub.value!;
              final level =
                  hub.levels.firstWhereOrNull(
                    (item) => item.code == hub.selectedLevel,
                  ) ??
                  hub.levels.firstOrNull;
              return RefreshIndicator(
                onRefresh: () => controller.loadHub(level: hub.selectedLevel),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppMainAppBar(
                        title: 'Học tập',
                        horizontalPadding: 0,
                      ),
                      AppGap.h18,
                      _LevelSelector(
                        levels: hub.levels,
                        selectedLevel: hub.selectedLevel,
                        onChanged: controller.selectLevel,
                      ),
                      AppGap.h14,
                      if (level != null) ...[
                        _LevelOverview(
                          level: level,
                          dailyGoal: hub.dailyGoal,
                          unitCount: hub.units
                              .where((u) => u.level == hub.selectedLevel)
                              .length,
                          onOpenCurriculum: () => Get.toNamed(
                            AppRoutes.curriculumUnits,
                            arguments: {'level': hub.selectedLevel},
                          ),
                        ),
                      ],
                      AppGap.h24,
                      const _SectionTitle(
                        title: 'Học phần bổ trợ',
                        subtitle:
                            'Ngữ pháp, từ vựng và flashcard hỗ trợ trực tiếp cho 4 kỹ năng.',
                      ),
                      AppGap.h12,
                      ...hub.supportTracks.map(
                        (track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SupportTile(
                            track: track,
                            onTap: () => controller.openSupport(track),
                          ),
                        ),
                      ),
                      AppGap.h22,
                      const _SectionTitle(
                        title: 'Thư viện lý thuyết ngữ pháp',
                        subtitle:
                            'Tra cứu toàn bộ lý thuyết ngữ pháp theo từng cấp độ A1 → C2.',
                      ),
                      AppGap.h12,
                      _GrammarTheoryEntryCard(
                        onTap: () => Get.toNamed(
                          AppRoutes.grammarTheory,
                          arguments: {'level': hub.selectedLevel},
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Hero card tổng quan cấp độ — gộp luôn lối vào lộ trình (Học theo Unit).
/// Bấm cả card → mở curriculum, bỏ card "Xem lộ trình" riêng để tránh trùng lặp.
class _LevelOverview extends StatelessWidget {
  const _LevelOverview({
    required this.level,
    required this.onOpenCurriculum,
    this.dailyGoal,
    this.unitCount = 0,
  });

  final LearningLevel level;
  final LearningDailyGoal? dailyGoal;
  final int unitCount;
  final VoidCallback onOpenCurriculum;

  @override
  Widget build(BuildContext context) {
    final onFixed = AppColors.onPrimaryFixed;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onOpenCurriculum,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
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
                  _LevelBadge(code: level.code, filled: true),
                  AppGap.w10,
                  Expanded(
                    child: Text(
                      level.title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: onFixed,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (dailyGoal != null)
                    Text(
                      '${dailyGoal!.earnedXp}/${dailyGoal!.targetXp} XP',
                      style: AppTypography.labelSmall.copyWith(
                        color: onFixed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              AppGap.h10,
              Text(
                level.description,
                style: AppTypography.bodyRegular.copyWith(
                  color: onFixed.withValues(alpha: 0.86),
                ),
              ),
              AppGap.h16,
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 8,
                  backgroundColor: onFixed.withValues(alpha: 0.22),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.tertiaryFixedDim,
                  ),
                ),
              ),
              AppGap.h8,
              Text(
                '${(level.progress * 100).round()}% hoàn thành cấp độ',
                style: AppTypography.labelSmall.copyWith(
                  color: onFixed.withValues(alpha: 0.9),
                ),
              ),
              AppGap.h16,
              // Đường kẻ mảnh ngăn phần overview với CTA vào lộ trình.
              Divider(
                height: 1,
                thickness: 1,
                color: onFixed.withValues(alpha: 0.20),
              ),
              AppGap.h14,
              Row(
                children: [
                  Icon(Icons.auto_stories_rounded, color: onFixed, size: 20),
                  AppGap.w10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Học theo Unit',
                          style: AppTypography.bodyRegular.copyWith(
                            color: onFixed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppGap.h2,
                        Text(
                          unitCount > 0
                              ? '$unitCount Unit · Lý thuyết → Bài tập → Quiz'
                              : 'Lý thuyết → Bài tập → Quiz, lên cấp khi hoàn thành',
                          style: AppTypography.labelSmall.copyWith(
                            color: onFixed.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppGap.w8,
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: onFixed.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: onFixed,
                      size: 18,
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

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({
    required this.levels,
    required this.selectedLevel,
    required this.onChanged,
  });

  final List<LearningLevel> levels;
  final String selectedLevel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        separatorBuilder: (_, __) => AppGap.w8,
        itemBuilder: (_, index) {
          final level = levels[index];
          final selected = level.code == selectedLevel;
          return InkWell(
            onTap: level.locked ? null : () => onChanged(level.code),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              width: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    level.code,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.onPrimaryFixed
                          : AppColors.onSurface,
                    ),
                  ),
                  if (level.locked) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: selected
                          ? AppColors.onPrimaryFixed
                          : AppColors.iconMuted,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Lối vào thư viện lý thuyết ngữ pháp (đọc lý thuyết theo level A1→C2).
class _GrammarTheoryEntryCard extends StatelessWidget {
  const _GrammarTheoryEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.skillGrammar.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.library_books_rounded,
                  color: AppColors.skillGrammar,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xem tất cả lý thuyết',
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      'Toàn bộ chủ đề ngữ pháp theo cấp độ, đọc nhanh không cần làm bài tập.',
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineMedium.copyWith(fontSize: 18)),
        AppGap.h4,
        Text(subtitle, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.track, required this.onTap});

  final LearningSupportTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _supportColor(track.type);
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: track.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_supportIcon(track.type), color: color, size: 23),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      track.description,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.code, this.filled = false});

  final String code;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final prefix = code.isEmpty ? '' : code.substring(0, 1);
    final Color bg = filled
        ? AppColors.onPrimaryFixed.withValues(alpha: 0.16)
        : switch (prefix) {
            'A' => AppColors.levelABg,
            'B' => AppColors.levelBBg,
            _ => AppColors.levelCBg,
          };
    final Color fg = filled
        ? AppColors.onPrimaryFixed
        : switch (prefix) {
            'A' => AppColors.levelAFg,
            'B' => AppColors.levelBFg,
            _ => AppColors.levelCFg,
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        code,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

IconData _supportIcon(String type) {
  return switch (type) {
    'grammar' => Icons.menu_book_rounded,
    'vocabulary' => Icons.style_rounded,
    'flashcard' => Icons.layers_rounded,
    'pronunciation' => Icons.mic_rounded,
    _ => Icons.school_rounded,
  };
}

Color _supportColor(String type) {
  return switch (type) {
    'grammar' => AppColors.skillGrammar,
    'vocabulary' => AppColors.skillVocabulary,
    'flashcard' => AppColors.tertiary,
    'pronunciation' => AppColors.skillListening,
    _ => AppColors.primary,
  };
}
