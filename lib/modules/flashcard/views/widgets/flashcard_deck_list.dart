import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class FlashcardDeckList extends GetView<FlashcardController> {
  const FlashcardDeckList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Your Decks',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAll,
                child: Text(
                  'View All',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppGap.h16,
        Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final deck in controller.decks) ...[
                _DeckCard(
                  deck: deck,
                  onStartStudy: () => controller.onStartStudy(deck),
                ),
                AppGap.h14,
              ],
              _CreateDeckTile(onTap: controller.onCreateDeck),
            ],
          ),
        )),
      ],
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck, required this.onStartStudy});

  final FlashcardDeck deck;
  final VoidCallback onStartStudy;

  static IconData _iconFor(String name) => switch (name) {
    'school' => Icons.school_rounded,
    'chat_bubble' => Icons.chat_bubble_rounded,
    'work' => Icons.work_rounded,
    _ => Icons.style_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Level badge row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(deck.iconBgColorHex),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _iconFor(deck.iconName),
                    color: Color(deck.iconColorHex),
                    size: 26,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    deck.levelLabel,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h14,
            // Title
            Text(
              deck.title,
              style: AppTypography.displayLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Row(
              children: [
                Text(
                  '${deck.cardCount} Cards',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  deck.category,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            AppGap.h16,
            // Mastery progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MASTERY',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(deck.mastery * 100).toInt()}%',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: deck.mastery,
                  backgroundColor: AppColors.secondaryContainer,
                  valueColor: const AlwaysStoppedAnimation(AppColors.tertiary),
                ),
              ),
            ),
            AppGap.h16,
            // Start Study button
            GestureDetector(
              onTap: onStartStudy,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Start Study',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateDeckTile extends StatelessWidget {
  const _CreateDeckTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 28, color: AppColors.iconMuted),
            ),
            AppGap.h12,
            Text(
              'Create New Deck',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add custom words and phrases',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
