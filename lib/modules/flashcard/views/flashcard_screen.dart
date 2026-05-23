import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/flashcard/views/widgets/flashcard_deck_list.dart';
import 'package:englishme/modules/flashcard/views/widgets/flashcard_stats.dart';
import 'package:englishme/modules/flashcard/views/widgets/flashcard_word_of_day.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class FlashcardScreen extends GetView<FlashcardController> {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: AppGap.h14),
            const SliverToBoxAdapter(
              child: AppMainAppBar(
                title: 'Học',
                showSearch: true,
                horizontalPadding: 0,
              ),
            ),
            SliverToBoxAdapter(child: AppGap.h24),
            const SliverToBoxAdapter(child: _LearnModules()),
            SliverToBoxAdapter(child: AppGap.h20),
            const SliverToBoxAdapter(child: FlashcardWordOfDay()),
            SliverToBoxAdapter(child: AppGap.h20),
            const SliverToBoxAdapter(child: FlashcardStats()),
            SliverToBoxAdapter(child: AppGap.h28),
            const SliverToBoxAdapter(child: FlashcardDeckList()),
            SliverToBoxAdapter(child: AppGap.h32),
          ],
        ),
      ),
    );
  }
}

class _LearnModules extends StatelessWidget {
  const _LearnModules();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _ModuleCard(
              icon: Icons.menu_book_rounded,
              title: 'Ngữ pháp',
              subtitle: 'Bài học nền tảng',
              onTap: () => Get.toNamed(AppRoutes.grammar),
            ),
          ),
          AppGap.w10,
          Expanded(
            child: _ModuleCard(
              icon: Icons.record_voice_over_rounded,
              title: 'Phát âm',
              subtitle: 'Luyện nói mỗi ngày',
              onTap: () => Get.toNamed(AppRoutes.pronunciation),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            AppGap.h8,
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
