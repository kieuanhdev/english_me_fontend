import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';
import 'package:englishme/modules/weak_skills/controllers/weak_skills_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// Màn "Kỹ năng cần cải thiện" — cá nhân hóa:
///   * Yếu kỹ năng gì (3 skill, yếu nhất lên đầu)
///   * Yếu ở đâu (phát âm: list từ hay sai + gợi ý)
///   * Luyện ngay (điều hướng; phát âm -> luyện NÓI với AI)
class WeakSkillsScreen extends GetView<WeakSkillsController> {
  const WeakSkillsScreen({super.key});

  ApiState _state(WeakSkillsLoad s) => switch (s) {
        WeakSkillsLoad.idle || WeakSkillsLoad.loading => ApiState.loading,
        WeakSkillsLoad.error => ApiState.error,
        WeakSkillsLoad.success => ApiState.success,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppMainAppBar(
              title: 'Kỹ năng cần cải thiện',
              showBack: true,
              showSettings: false,
              onBack: Get.back,
            ),
            Expanded(
              child: Obx(
                () => ApiStateView(
                  state: _state(controller.loadState.value),
                  errorMessage: 'Không tải được dữ liệu kỹ năng.',
                  onRetry: controller.load,
                  builder: (_) => _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!controller.hasData) {
      return const _EmptyState();
    }
    final items = controller.skills;
    final pron = controller.pronInsight.value;

    return RefreshIndicator(
      onRefresh: controller.load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Dựa trên dữ liệu học của bạn, đây là các kỹ năng nên ưu tiên luyện.',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          AppGap.h16,
          for (final s in items) ...[
            _SkillCard(
              item: s,
              // Chỉ skill phát âm mới có chi tiết "yếu ở đâu" (từ hay sai).
              weakWords: s.key == 'pronunciation'
                  ? (pron?.weakestWords ?? const [])
                  : const [],
              pronAvgScore: s.key == 'pronunciation' ? pron?.averageScore : null,
              onPractice: () => controller.practice(s.key),
              onDrill: s.key == 'pronunciation'
                  ? controller.practicePronunciationDrill
                  : null,
            ),
            AppGap.h14,
          ],
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.item,
    required this.weakWords,
    required this.pronAvgScore,
    required this.onPractice,
    required this.onDrill,
  });

  final WeakSkillItem item;
  final List<WeakWord> weakWords;
  final int? pronAvgScore;
  final VoidCallback onPractice;
  final VoidCallback? onDrill;

  IconData get _icon => switch (item.key) {
        'vocabulary' => Icons.menu_book_rounded,
        'grammar' => Icons.rule_rounded,
        'reading' => Icons.article_rounded,
        'listening' => Icons.headphones_rounded,
        'speaking' => Icons.record_voice_over_rounded,
        'writing' => Icons.edit_note_rounded,
        'pronunciation' => Icons.record_voice_over_rounded,
        _ => Icons.school_rounded,
      };

  /// Nhãn nút "luyện ngay" theo skill — khớp với điều hướng trong controller.
  String get _practiceLabel => switch (item.key) {
        'pronunciation' || 'speaking' => 'Luyện nói với AI',
        'listening' => 'Luyện nghe',
        'reading' => 'Luyện đọc',
        'writing' => 'Luyện viết',
        'grammar' => 'Học ngữ pháp',
        'vocabulary' => 'Ôn từ vựng',
        _ => 'Luyện ngay',
      };

  @override
  Widget build(BuildContext context) {
    final Color accent = item.isWeak ? AppColors.tertiary : AppColors.primary;
    final pct = (item.share * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: item.isWeak
              ? accent.withValues(alpha: 0.4)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + tên + badge "Cần luyện"
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_icon, color: accent, size: 21),
              ),
              AppGap.w12,
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              if (item.isWeak)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Cần luyện',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          AppGap.h12,
          // Thanh tiến độ tương quan
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: item.share.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ),
              AppGap.w8,
              Text(
                '$pct%',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          AppGap.h8,
          Text(
            item.reason,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),

          // "Yếu ở đâu" — chi tiết phát âm (từ hay sai).
          if (item.key == 'pronunciation' && weakWords.isNotEmpty) ...[
            AppGap.h14,
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 15, color: AppColors.tertiary),
                AppGap.w8,
                Text(
                  'Từ bạn hay phát âm sai'
                  '${pronAvgScore != null ? ' (TB $pronAvgScore điểm)' : ''}',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            AppGap.h8,
            ...weakWords.take(5).map((w) => _WeakWordRow(word: w)),
          ],

          AppGap.h16,
          // Nút luyện ngay
          Row(
            children: [
              Expanded(
                child: _PracticeButton(
                  label: _practiceLabel,
                  icon: item.key == 'pronunciation'
                      ? Icons.smart_toy_rounded
                      : Icons.play_arrow_rounded,
                  accent: accent,
                  filled: true,
                  onTap: onPractice,
                ),
              ),
              if (onDrill != null) ...[
                AppGap.w8,
                Expanded(
                  child: _PracticeButton(
                    label: 'Đọc theo mẫu',
                    icon: Icons.mic_rounded,
                    accent: AppColors.primary,
                    filled: false,
                    onTap: onDrill!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _WeakWordRow extends StatelessWidget {
  const _WeakWordRow({required this.word});

  final WeakWord word;

  Color _issueColor() => switch (word.lastIssueType) {
        'critical' => AppColors.danger,
        'minor' => AppColors.accentWarm,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final c = _issueColor();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          AppGap.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word.word,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                    AppGap.w8,
                    Text(
                      '${word.avgScore} điểm',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c,
                      ),
                    ),
                  ],
                ),
                if (word.suggestion != null &&
                    word.suggestion!.trim().isNotEmpty)
                  Text(
                    word.suggestion!,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeButton extends StatelessWidget {
  const _PracticeButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? accent : accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: filled ? AppColors.onPrimaryFixed : accent),
              AppGap.w8,
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: filled ? AppColors.onPrimaryFixed : accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded,
                size: 56, color: AppColors.primary.withValues(alpha: 0.5)),
            AppGap.h16,
            Text(
              'Chưa đủ dữ liệu để phân tích',
              style: AppTypography.headlineMedium.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            AppGap.h8,
            Text(
              'Hãy học vài bài (từ vựng, ngữ pháp, phát âm) để hệ thống '
              'phân tích kỹ năng nào bạn cần cải thiện.',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
