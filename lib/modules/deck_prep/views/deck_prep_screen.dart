import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/deck_prep/controllers/deck_prep_controller.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';

const Color _kOnSurfaceVariant = Color(0xFF454652);
const Color _kInventoryAccent = Color(0xFFFFB870);

class DeckPrepScreen extends StatelessWidget {
  const DeckPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DeckPrepController>()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) Get.back();
      });
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: CommonAppBar(
          title: 'EnglishMe',
          isTranslate: false,
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final c = Get.find<DeckPrepController>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommonAppBar(
        title: 'EnglishMe',
        isTranslate: false,
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            offset: const Offset(0, 48),
            onSelected: (v) {
              if (v == 'edit') c.openEditDesk();
              if (v == 'delete') c.confirmDeleteThisDesk();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(T.deckEditDeck.tr)),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  T.deckDeleteDeck.tr,
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.errorMessage.isNotEmpty) {
            return _ErrorState(
              message: c.errorMessage.value,
              onRetry: c.retryLoad,
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeckHeader(controller: c),
                AppGap.h24,
                _WeeklyMasteryCard(controller: c),
                AppGap.h20,
                _PrimaryActions(controller: c),
                AppGap.h28,
                const _InventoryHeader(),
                AppGap.h16,
                ...c.previewCards.map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _InventoryWordCard(
                        card: card,
                        onSpeak: () => c.speakWord(card.word),
                        onEdit: () => c.onEditCard(card),
                      ),
                    )),
                if (c.previewCards.isEmpty) const _EmptyPreview(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.danger),
            ),
            AppGap.h16,
            AppButton(
              label: T.actionRetry.tr,
              onPressed: onRetry,
              variant: AppButtonVariant.primary,
              isTranslate: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({required this.controller});

  final DeckPrepController controller;

  String _levelLabel(String cefr) {
    final u = cefr.toUpperCase();
    return switch (u) {
      'A1' => T.deckLevelA1.tr,
      'A2' => T.deckLevelA2.tr,
      'B1' => T.deckLevelB1.tr,
      'B2' => T.deckLevelB2.tr,
      'C1' => T.deckLevelC1.tr,
      'C2' => T.deckLevelC2.tr,
      _ => T.deckLevelUnknown.trParams({'level': cefr}),
    };
  }

  @override
  Widget build(BuildContext context) {
    final desk = controller.desk;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.deckVocabSet.tr,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.tertiary,
                ),
              ),
              AppGap.h6,
              Text(
                desk.title,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 26,
                  height: 1.15,
                  color: AppColors.primary,
                ),
              ),
              AppGap.h6,
              Obx(
                () => Text(
                  '${T.deckCardCountLabel.trParams({'count': controller.cardCount.toString()})} • ${_levelLabel(desk.cefrLevel)}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: AppColors.tertiary, size: 22),
              const SizedBox(width: 6),
              Text(
                '4.9',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyMasteryCard extends StatelessWidget {
  const _WeeklyMasteryCard({required this.controller});

  final DeckPrepController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pct = controller.weeklyMasteryPercent;
      return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                T.deckProgressWeek.tr,
                style: AppTypography.displayLarge.copyWith(fontSize: 17),
              ),
              Text(
                '$pct%',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 17,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          AppGap.h14,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 10,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.secondaryContainer),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (pct / 100.0).clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: ColoredBox(color: AppColors.tertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppGap.h14,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                T.deckNewCardsCount.trParams({'count': controller.newCardsCount.toString()}),
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                T.deckMasteredCardsCount.trParams({'count': controller.masteredCardsCount.toString()}),
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    });
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.controller});

  final DeckPrepController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.startStudySession,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    T.actionStartSession.tr,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppGap.h12,
        AppButton(
          label: T.actionAddCard.tr,
          onPressed: controller.onAddCard,
          variant: AppButtonVariant.secondary,
          height: 56,
          leading: Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
          isTranslate: false,
        ),
      ],
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          T.deckCardList.tr,
          style: AppTypography.displayLarge.copyWith(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        Row(
          children: [
            Icon(Icons.sort_rounded, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              T.deckNewest.tr,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InventoryWordCard extends StatelessWidget {
  const _InventoryWordCard({
    required this.card,
    required this.onSpeak,
    required this.onEdit,
  });

  final VocabWord card;
  final VoidCallback onSpeak;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final vi = card.definitionVi;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(color: AppColors.neutralShadow, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 12, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        card.word,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onSpeak,
                      icon: Icon(
                        Icons.volume_up_rounded,
                        size: 22,
                        color: AppColors.iconMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
                if (card.ipa.isNotEmpty) ...[
                  AppGap.h6,
                  Text(
                    card.ipa,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                AppGap.h12,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _kInventoryAccent, width: 4),
                    ),
                  ),
                  child: Text(
                    vi,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: _kOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.iconMuted,
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          T.deckEmptyCards.tr,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
