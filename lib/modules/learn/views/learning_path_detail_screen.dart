import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/modules/learn/repositories/learning_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class LearningPathDetailScreen extends StatefulWidget {
  const LearningPathDetailScreen({
    super.key,
    required this.level,
    required this.pathId,
  });

  final String level;
  final String pathId;

  @override
  State<LearningPathDetailScreen> createState() =>
      _LearningPathDetailScreenState();
}

class _LearningPathDetailScreenState extends State<LearningPathDetailScreen> {
  late final LearningRepository _repo;
  late Future<LearningPathDetail> _future;

  @override
  void initState() {
    super.initState();
    _repo = Get.find<LearningRepository>();
    _future = _load();
  }

  Future<LearningPathDetail> _load() {
    return _repo.getPathDetail(level: widget.level, pathId: widget.pathId);
  }

  void _reload() {
    if (!mounted) return;
    final next = _load();
    setState(() {
      _future = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FutureBuilder<LearningPathDetail>(
          future: _future,
          builder: (context, snapshot) {
            final state = snapshot.connectionState == ConnectionState.waiting
                ? ApiState.loading
                : snapshot.hasError
                ? ApiState.error
                : snapshot.data == null
                ? ApiState.empty
                : ApiState.success;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ApiStateView(
                state: state,
                errorMessage: 'Không tải được path học tập.',
                emptyMessage: 'Path này chưa có hoạt động.',
                onRetry: _reload,
                builder: (_) {
                  final path = snapshot.data!;
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
                                  path.title,
                                  style: AppTypography.displayLarge.copyWith(
                                    fontSize: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                                AppGap.h2,
                                Text(
                                  '${path.level} • ${path.activities.length} hoạt động',
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
                      _PathHeader(path: path),
                      AppGap.h16,
                      Expanded(
                        child: path.activities.isEmpty
                            ? Center(
                                child: Text(
                                  'Path này chưa có hoạt động.',
                                  style: AppTypography.bodyRegular,
                                ),
                              )
                            : ListView.separated(
                                itemCount: path.activities.length,
                                separatorBuilder: (_, __) => AppGap.h10,
                                itemBuilder: (_, index) => _ActivityTile(
                                  activity: path.activities[index],
                                  onTap: () async {
                                    await Get.toNamed(
                                      AppRoutes.curriculumLessonPlayer,
                                      arguments: {
                                        'lessonId': path.activities[index].id,
                                      },
                                    );
                                    if (mounted) _reload();
                                  },
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PathHeader extends StatelessWidget {
  const _PathHeader({required this.path});

  final LearningPathDetail path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
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
                child: Icon(Icons.route_rounded, color: AppColors.primary),
              ),
              AppGap.w12,
              Expanded(
                child: Text(
                  path.description,
                  style: AppTypography.bodyRegular,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppGap.h14,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: path.progress,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          AppGap.h8,
          Text(
            '${(path.progress * 100).round()}% hoàn thành path',
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.onTap});

  final LearningPathActivity activity;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final color = activity.isFailed
        ? AppColors.danger
        : _skillColor(activity.skill);
    final disabled = activity.isLocked;
    return Material(
      color: disabled
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: disabled ? null : () { onTap(); },
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
                child: Icon(_statusIcon(activity), color: color, size: 23),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _SkillPill(skill: activity.skill, color: color),
                        AppGap.w8,
                        Text(
                          '${activity.durationMinutes} phút',
                          style: AppTypography.labelXSmall,
                        ),
                      ],
                    ),
                    AppGap.h8,
                    Text(
                      '${activity.order}. ${activity.title}',
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      activity.subtitle,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              Icon(
                activity.isCompleted
                    ? Icons.check_circle_rounded
                    : activity.isFailed
                    ? Icons.cancel_rounded
                    : activity.isLocked
                    ? Icons.lock_rounded
                    : Icons.chevron_right_rounded,
                color: activity.isCompleted
                    ? AppColors.success
                    : activity.isFailed
                    ? AppColors.danger
                    : AppColors.iconMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.skill, required this.color});

  final String skill;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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

IconData _statusIcon(LearningPathActivity activity) {
  if (activity.isCompleted) return Icons.check_rounded;
  if (activity.isFailed) return Icons.close_rounded;
  if (activity.isLocked) return Icons.lock_rounded;
  if (activity.status == 'in_progress') return Icons.play_arrow_rounded;
  return _skillIcon(activity.skill);
}

IconData _skillIcon(String skill) {
  return switch (skill) {
    'listening' => Icons.headphones_rounded,
    'speaking' => Icons.record_voice_over_rounded,
    'reading' => Icons.article_rounded,
    'writing' => Icons.edit_note_rounded,
    'grammar' => Icons.menu_book_rounded,
    'vocabulary' => Icons.style_rounded,
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
