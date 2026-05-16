import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppMainAppBar(title: 'Luyện tập'),
              AppGap.h20,
              const _ExerciseTile(
                title: 'Bài tập ngữ pháp',
                subtitle: 'Luyện theo thì, cấu trúc câu và lỗi phổ biến',
                icon: Icons.menu_book_rounded,
              ),
              AppGap.h12,
              const _ExerciseTile(
                title: 'Bài tập từ vựng',
                subtitle: 'Ôn từ theo chủ đề và theo cấp độ',
                icon: Icons.style_rounded,
              ),
              AppGap.h12,
              const _ExerciseTile(
                title: 'Ôn lỗi gần đây',
                subtitle: 'Tập trung vào câu trả lời sai để tiến bộ nhanh',
                icon: Icons.replay_circle_filled_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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
