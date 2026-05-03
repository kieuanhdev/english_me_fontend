import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                AppGap.h24,
                _ScoreCard(score: result.score, total: result.totalQuestions),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
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
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.secondaryContainer,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.items});

  final List items;

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
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final bool correct = item.isCorrect as bool;
    final Color borderColor = correct ? AppColors.success : AppColors.danger;
    final Color bgColor = correct ? AppColors.successSoft : AppColors.dangerSoft;
    final Color textColor = correct ? AppColors.successDark : AppColors.dangerDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
            child: Icon(
              correct ? Icons.check : Icons.close,
              color: Colors.white,
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
                if ((item.explanation as String).isNotEmpty) ...[
                  AppGap.h6,
                  Text(
                    item.explanation as String,
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0xFF1A2E7A), offset: Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Get.offAllNamed('/home'),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          'VÀO HỌC NGAY',
          style: AppTypography.labelMedium.copyWith(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
