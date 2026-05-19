import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/exercise/controllers/exercise_controller.dart';
import 'package:englishme/modules/exercise/models/exercise_model.dart';
import 'package:englishme/theme/app_theme.dart';

class ExerciseScreen extends GetView<ExerciseController> {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppMainAppBar(title: 'Luyện tập'),
              AppGap.h8,
              Text(
                'Chọn loại bài tập',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              AppGap.h20,
              _CategoryCard(
                title: 'Bài tập từ vựng',
                subtitle: 'Trắc nghiệm nghĩa, ngữ cảnh và cách dùng từ',
                icon: Icons.style_rounded,
                accentColor: AppColors.skillVocabulary,
                questionCount: 10,
                onTap: () => controller.startSession(ExerciseCategory.vocabulary),
              ),
              AppGap.h14,
              _CategoryCard(
                title: 'Bài tập ngữ pháp',
                subtitle: 'Luyện thì, cấu trúc câu và các quy tắc ngữ pháp',
                icon: Icons.menu_book_rounded,
                accentColor: AppColors.skillGrammar,
                questionCount: 10,
                onTap: () => controller.startSession(ExerciseCategory.grammar),
              ),
              AppGap.h28,
              _HowItWorksSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.questionCount,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final int questionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(color: AppColors.shadowSoft, blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Badge(
                        icon: Icons.quiz_rounded,
                        label: '$questionCount câu hỏi',
                        color: accentColor,
                      ),
                      AppGap.w8,
                      _Badge(
                        icon: Icons.timer_outlined,
                        label: '~5 phút',
                        color: AppColors.iconMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppGap.w12,
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── How It Works ─────────────────────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Cách thức hoạt động',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppGap.h10,
          ...[
            'Mỗi bài gồm 10 câu hỏi trắc nghiệm',
            'Chọn đáp án → xem kết quả ngay lập tức',
            'Xem giải thích cho mỗi câu sau khi trả lời',
            'Kết quả được lưu để theo dõi tiến độ',
          ].map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                  AppGap.w8,
                  Expanded(
                    child: Text(
                      text,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
