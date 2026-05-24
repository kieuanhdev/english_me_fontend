import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_desk_controller.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabDeckList extends GetView<VocabDeskController> {
  const VocabDeckList({super.key});

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
                T.flashcardDecks.tr,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAll,
                child: Text(
                  T.actionViewAll.tr,
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
        Obx(() {
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.errorMessage.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                  AppGap.h12,
                  GestureDetector(
                    onTap: controller.loadDesks,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        T.actionRetry.tr,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onPrimaryFixed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final desk in controller.desks) ...[
                  _DeckCard(
                    desk: desk,
                    onStartStudy: () => controller.onStartStudy(desk),
                    onEdit: () => controller.onEditDeck(desk),
                    onDelete: () => controller.onDeleteDeck(desk),
                  ),
                  AppGap.h14,
                ],
                _CreateDeckTile(onTap: controller.onCreateDeck),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Deck Card ────────────────────────────────────────────────────────────────

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.desk,
    required this.onStartStudy,
    required this.onEdit,
    required this.onDelete,
  });

  final VocabDesk desk;
  final VoidCallback onStartStudy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Color _bgColor(String cefr) => switch (cefr.toUpperCase()) {
        'A1' || 'A2' => AppColors.levelABg,
        'B1' || 'B2' => AppColors.levelBBg,
        'C1' || 'C2' => AppColors.levelCBg,
        _ => AppColors.surfaceContainerLow,
      };

  static Color _fgColor(String cefr) => switch (cefr.toUpperCase()) {
        'A1' || 'A2' => AppColors.levelAFg,
        'B1' || 'B2' => AppColors.levelBFg,
        'C1' || 'C2' => AppColors.levelCFg,
        _ => AppColors.textSecondary,
      };

  static IconData _icon(String cefr) => switch (cefr.toUpperCase()) {
        'A1' || 'A2' => Icons.eco_rounded,
        'B1' || 'B2' => Icons.school_rounded,
        'C1' || 'C2' => Icons.military_tech_rounded,
        _ => Icons.style_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(desk.cefrLevel);
    final fg = _fgColor(desk.cefrLevel);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(color: AppColors.neutralShadow, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: Icon(_icon(desk.cefrLevel), color: fg, size: 26),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    desk.cefrLevel,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: fg,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 22, color: AppColors.iconMuted),
                  padding: EdgeInsets.zero,
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(T.flashcardEditDeck.tr)),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        T.flashcardDeleteDeck.tr,
                        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppGap.h14,
            Text(desk.title, style: AppTypography.displayLarge.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              T.labelVocabCount.tr.replaceAll('{count}', '${desk.flashcardCount}'),
              style: AppTypography.bodyLarge.copyWith(fontSize: 13, color: AppColors.textSecondary),
            ),
            AppGap.h16,
            GestureDetector(
              onTap: onStartStudy,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: AppColors.onPrimaryFixed, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      T.deckStartJourney.tr,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryFixed,
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

// ─── Create Deck Tile ─────────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.outlineVariant, width: 2),
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
              child: Icon(Icons.add_rounded, size: 28, color: AppColors.iconMuted),
            ),
            AppGap.h12,
            Text(
              T.flashcardCreateNew.tr,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              T.flashcardAddCustom.tr,
              style: AppTypography.bodyLarge.copyWith(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
