import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
import 'package:englishme/modules/placement_test/models/placement_test_models.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:get/get.dart';

class PlacementResultScreen extends GetView<PlacementTestController> {
  const PlacementResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          final result = controller.testResult.value;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              children: [
                AppGap.h16,
                _LevelBadge(level: result.resultLevel),
                AppGap.h20,
                Text(
                  'Kết quả của bạn',
                  style: AppTypography.displayLarge.copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                AppGap.h8,
                Text(
                  'Trình độ ${result.resultLevel} theo chuẩn CEFR',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (result.canGoHigherThanC1 &&
                    result.aboveLevelMessage.isNotEmpty) ...[
                  AppGap.h16,
                  _AboveLevelCard(message: result.aboveLevelMessage),
                ],
                AppGap.h24,
                _ScoreCard(score: result.score, total: result.totalQuestions),
                AppGap.h24,
                _SkillBreakdown(
                  review: result.review,
                  // Map questionId → skillCategory từ các câu đã làm (CAT),
                  // vì /complete response KHÔNG trả skillCategory trong review[].
                  questionSkillMap: {
                    for (final q in controller.answeredQuestions)
                      q.id: q.skillCategory,
                  },
                ),
                AppGap.h24,
                _ReviewList(items: result.review),
                AppGap.h28,
                _GoToDashboardButton(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final String level;

  static Color _colorFor(String level) {
    return switch (level.toUpperCase()) {
      'A1' => const Color(0xFF9E9E9E),
      'A2' => const Color(0xFF42A5F5),
      'B1' => const Color(0xFF66BB6A),
      'B2' => const Color(0xFFFFA726),
      'C1' => const Color(0xFFEF5350),
      'C2' => const Color(0xFFAB47BC),
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(level);
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            level.toUpperCase(),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 40,
              color: color,
              letterSpacing: 2,
            ),
          ),
          Text(
            'CEFR',
            style: AppTypography.labelMedium.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 12,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card nổi bật khi học viên kịch trần C1 và có dấu hiệu giỏi hơn (gợi ý C2).
class _AboveLevelCard extends StatelessWidget {
  const _AboveLevelCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.rocket_launch_rounded, size: 22, color: AppColors.success),
              AppGap.w12,
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.successDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h12,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.placementLevelPicker),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Tự chọn C2'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
                textStyle: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? score / total : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.neutralShadow, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$score/$total',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 36,
              color: AppColors.primary,
            ),
          ),
          AppGap.h8,
          Text(
            'câu trả lời đúng',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          AppGap.h14,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.secondaryContainer,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phân tích kết quả theo kỹ năng (skillCategory) — chứng minh Adaptive CEFR.
///
/// [questionSkillMap]: Map questionId -> skillCategory xây từ controller.answeredQuestions.
/// Cần thiết vì /complete response KHÔNG trả skillCategory trong review[].
/// Backend trả PascalCase ("Grammar") → widget normalize toLower để khớp _skillLabel.
class _SkillBreakdown extends StatelessWidget {
  const _SkillBreakdown({
    required this.review,
    required this.questionSkillMap,
  });

  final List<ReviewItemModel> review;
  final Map<String, String> questionSkillMap;

  static const _skillLabel = {
    'vocabulary': 'Từ vựng',
    'grammar': 'Ngữ pháp',
    'listening': 'Luyện nghe',
    'reading': 'Đọc hiểu',
    'writing': 'Viết',
  };

  static IconData _iconFor(String skill) => switch (skill) {
        'vocabulary' => Icons.psychology_rounded,
        'grammar' => Icons.menu_book_rounded,
        'listening' => Icons.headphones_rounded,
        'reading' => Icons.chrome_reader_mode_rounded,
        'writing' => Icons.edit_rounded,
        _ => Icons.quiz_rounded,
      };

  @override
  Widget build(BuildContext context) {
    // Ưu tiên lấy skillCategory từ questionSkillMap (từ /start response),
    // fallback về item.skillCategory (nếu backend /complete có trả).
    // Normalize toLower để khớp _skillLabel keys (backend dùng PascalCase).
    final Map<String, List<ReviewItemModel>> grouped = {};
    for (final item in review) {
      final raw = (questionSkillMap[item.questionId] ?? item.skillCategory).trim();
      if (raw.isEmpty) continue;
      grouped.putIfAbsent(raw.toLowerCase(), () => []).add(item);
    }
    if (grouped.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích theo kỹ năng',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h4,
          Text(
            'Dựa trên câu trả lời, hệ thống xác định kỹ năng yếu để gợi ý lộ trình.',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          AppGap.h16,
          ...grouped.entries.map((e) {
            final skill = e.key;
            final items = e.value;
            final correct = items.where((i) => i.isCorrect).length;
            final total = items.length;
            final ratio = total > 0 ? correct / total : 0.0;
            final label = _skillLabel[skill] ?? skill;
            final color = ratio >= 0.7
                ? AppColors.success
                : ratio >= 0.4
                    ? AppColors.accentWarm
                    : AppColors.danger;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_iconFor(skill), size: 16, color: color),
                      AppGap.w8,
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$correct/$total',
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  AppGap.h6,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: SizedBox(
                      height: 7,
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.items});

  final List<ReviewItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết từng câu',
          style: AppTypography.displayLarge.copyWith(fontSize: 18),
        ),
        AppGap.h12,
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReviewTile(index: i + 1, item: item),
          );
        }),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.index, required this.item});

  final int index;
  final ReviewItemModel item;

  @override
  Widget build(BuildContext context) {
    final bool correct = item.isCorrect;
    final Color borderColor = correct ? AppColors.success : AppColors.danger;
    final Color bgColor =
        correct ? AppColors.successSoft : AppColors.dangerSoft;
    final Color textColor =
        correct ? AppColors.successDark : AppColors.dangerDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              correct ? Icons.check : Icons.close,
              color: AppColors.onPrimaryFixed,
              size: 16,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu $index: ${item.question}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                AppGap.h6,
                Text(
                  'Bạn chọn: ${item.selectedAnswer}   •   Đúng: ${item.correctAnswer}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (item.explanation.isNotEmpty) ...[
                  AppGap.h6,
                  Text(
                    item.explanation,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoToDashboardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'VÀO HỌC NGAY',
      isTranslate: false,
      onPressed: () => ShellController.goToTab(0),
      radius: AppRadius.md,
      textStyle: AppTypography.labelMedium.copyWith(fontSize: 18),
    );
  }
}
