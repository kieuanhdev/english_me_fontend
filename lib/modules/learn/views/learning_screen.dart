import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/learn/controllers/learning_controller.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
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
                      const AppMainAppBar(title: 'Học tập'),
                      AppGap.h18,
                      if (level != null) ...[
                        _LevelOverview(level: level, dailyGoal: hub.dailyGoal),
                        AppGap.h16,
                      ],
                      _LevelSelector(
                        levels: hub.levels,
                        selectedLevel: hub.selectedLevel,
                        onChanged: controller.selectLevel,
                      ),
                      AppGap.h22,
                      _SectionTitle(
                        title: 'Path học ${hub.selectedLevel}',
                        subtitle:
                            'Mỗi path tập trung vào một chủ đề và trộn bài tập của nhiều kỹ năng.',
                      ),
                      AppGap.h12,
                      ...hub.paths.map(
                        (path) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PathTile(
                            path: path,
                            onTap: () => controller.openPath(path),
                          ),
                        ),
                      ),
                      AppGap.h24,
                      if (hub.paths.isEmpty) ...[
                        const _SectionTitle(
                          title: '4 kỹ năng chính',
                          subtitle:
                              'Lộ trình nghe, nói, đọc, viết được chia theo từng cấp CEFR.',
                        ),
                        AppGap.h12,
                        GridView.builder(
                          itemCount: hub.skillTracks.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.88,
                              ),
                          itemBuilder: (_, index) => _SkillCard(
                            skill: hub.skillTracks[index],
                            levelCode: hub.selectedLevel,
                            onTap: () =>
                                controller.openSkill(hub.skillTracks[index]),
                          ),
                        ),
                        AppGap.h24,
                        _SectionTitle(
                          title: 'Lộ trình ${hub.selectedLevel}',
                          subtitle:
                              'Các unit tổng hợp bài học từ cả 4 kỹ năng.',
                        ),
                        AppGap.h12,
                        ...hub.units.map(
                          (unit) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _UnitTile(unit: unit),
                          ),
                        ),
                      ],
                      AppGap.h16,
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

class _LevelOverview extends StatelessWidget {
  const _LevelOverview({required this.level, this.dailyGoal});

  final LearningLevel level;
  final LearningDailyGoal? dailyGoal;

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
              _LevelBadge(code: level.code, filled: true),
              AppGap.w10,
              Expanded(
                child: Text(
                  level.title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.onPrimaryFixed,
                    fontSize: 20,
                  ),
                ),
              ),
              if (dailyGoal != null)
                Text(
                  '${dailyGoal!.earnedXp}/${dailyGoal!.targetXp} XP',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onPrimaryFixed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          AppGap.h10,
          Text(
            level.description,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.86),
            ),
          ),
          AppGap.h16,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: level.progress,
              minHeight: 8,
              backgroundColor: AppColors.onPrimaryFixed.withValues(alpha: 0.22),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.tertiaryFixedDim,
              ),
            ),
          ),
          AppGap.h8,
          Text(
            '${(level.progress * 100).round()}% hoàn thành cấp độ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.9),
            ),
          ),
        ],
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

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.skill,
    required this.levelCode,
    required this.onTap,
  });

  final LearningSkillTrack skill;
  final String levelCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(
      skill.accentColor,
      fallback: _skillColor(skill.type),
    );
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: skill.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(_skillIcon(skill), color: color, size: 23),
                  ),
                  const Spacer(),
                  _LevelBadge(code: levelCode),
                ],
              ),
              AppGap.h12,
              Text(
                skill.title,
                style: AppTypography.headlineMedium.copyWith(fontSize: 16),
              ),
              AppGap.h4,
              Text(
                '${skill.completedLessons}/${skill.totalLessons} bài',
                style: AppTypography.labelSmall.copyWith(color: color),
              ),
              AppGap.h6,
              Expanded(
                child: Text(
                  skill.description,
                  style: AppTypography.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGap.h8,
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: skill.progress,
                  minHeight: 5,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({required this.path, required this.onTap});

  final LearningPath path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = path.isLocked;
    return Material(
      color: disabled
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: disabled ? null : onTap,
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      disabled ? Icons.lock_rounded : Icons.route_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${path.level} • ${path.title}',
                          style: AppTypography.bodyRegular.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppGap.h2,
                        Text(
                          path.description,
                          style: AppTypography.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppGap.w8,
                  Icon(
                    path.isCompleted
                        ? Icons.check_circle_rounded
                        : disabled
                        ? Icons.lock_rounded
                        : Icons.chevron_right_rounded,
                    color: path.isCompleted
                        ? AppColors.success
                        : AppColors.iconMuted,
                  ),
                ],
              ),
              AppGap.h12,
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: path.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.progressTrack,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  AppGap.w10,
                  Text(
                    '${path.completedActivityCount}/${path.activityCount}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (path.skillsCoverage.isNotEmpty) ...[
                AppGap.h10,
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: path.skillsCoverage
                      .map((skill) => _SkillCoveragePill(skill: skill))
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillCoveragePill extends StatelessWidget {
  const _SkillCoveragePill({required this.skill});

  final String skill;

  @override
  Widget build(BuildContext context) {
    final color = _skillColor(skill);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        _skillLabel(skill),
        style: AppTypography.labelXSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit});

  final LearningUnit unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              unit.status == 'locked'
                  ? Icons.lock_rounded
                  : Icons.route_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${unit.level} • ${unit.title}',
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
          Text(
            '${unit.completedLessonCount}/${unit.lessonCount}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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

IconData _skillIcon(LearningSkillTrack skill) {
  return switch (skill.type) {
    'listening' => Icons.headphones_rounded,
    'speaking' => Icons.record_voice_over_rounded,
    'reading' => Icons.article_rounded,
    'writing' => Icons.edit_note_rounded,
    _ => Icons.school_rounded,
  };
}

String _skillLabel(String skill) {
  return switch (skill) {
    'listening' => 'Nghe',
    'speaking' => 'Nói',
    'reading' => 'Đọc',
    'writing' => 'Viết',
    'grammar' => 'Ngữ pháp',
    'vocabulary' => 'Từ vựng',
    _ => skill,
  };
}

Color _skillColor(String skill) {
  return switch (skill) {
    'listening' => AppColors.skillListening,
    'speaking' => AppColors.tertiary,
    'reading' => AppColors.success,
    'writing' => AppColors.primary,
    'grammar' => AppColors.skillGrammar,
    'vocabulary' => AppColors.skillVocabulary,
    _ => AppColors.primary,
  };
}

IconData _supportIcon(String type) {
  return switch (type) {
    'grammar' => Icons.menu_book_rounded,
    'vocabulary' => Icons.style_rounded,
    'flashcard' => Icons.layers_rounded,
    _ => Icons.school_rounded,
  };
}

Color _supportColor(String type) {
  return switch (type) {
    'grammar' => AppColors.skillGrammar,
    'vocabulary' => AppColors.skillVocabulary,
    'flashcard' => AppColors.tertiary,
    _ => AppColors.primary,
  };
}

Color _colorFromHex(String hex, {required Color fallback}) {
  final normalized = hex.replaceAll('#', '').trim();
  if (normalized.length != 6) return fallback;
  final value = int.tryParse('FF$normalized', radix: 16);
  return value == null ? fallback : Color(value);
}
