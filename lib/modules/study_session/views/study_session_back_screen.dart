import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class StudySessionBackScreen extends StatelessWidget {
  const StudySessionBackScreen({super.key});

  StudySessionController get controller => Get.find<StudySessionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Obx(
            () => StudySessionRatingGrid(
              onRate: controller.rateCard,
              isLoading: controller.isReviewing.value,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.closeSession,
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      controller.deskTitle.isNotEmpty
                          ? controller.deskTitle
                          : 'Daily Session',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_rounded, size: 22),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => _ProgressSection(
                    current: controller.currentIndex.value + 1,
                    total: controller.totalCards,
                  )),
            ),
            AppGap.h16,
            // Card scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Obx(() => StudySessionFlashcardBack(
                      card: controller.currentCard,
                      onSpeak: controller.speak,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress ────────────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: '$current',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: '/$total',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.iconMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'PROGRESS',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.iconMuted,
              ),
            ),
          ],
        ),
        AppGap.h8,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: AppColors.progressTrack),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentWarm, Color(0xFFD4761A)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Flashcard Back ───────────────────────────────────────────────────────────

class StudySessionFlashcardBack extends StatelessWidget {
  const StudySessionFlashcardBack({
    super.key,
    required this.card,
    required this.onSpeak,
  });

  final VocabWord card;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final posLabel = card.pos.isNotEmpty ? card.pos.first.toUpperCase() : '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 32, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Part of speech + audio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (posLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.levelCBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          posLabel,
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.levelCFg,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    GestureDetector(
                      onTap: onSpeak,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                        child: Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 22),
                      ),
                    ),
                  ],
                ),
                AppGap.h20,
                // Word
                Text(
                  card.word,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
                if (card.ipa.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    card.ipa,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                AppGap.h24,
                Container(height: 1.5, color: AppColors.surfaceContainerLow),
                AppGap.h20,
                // Vietnamese meaning
                if (card.definitionVi.isNotEmpty)
                  Text(
                    card.definitionVi,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.levelCFg,
                    ),
                  ),
                AppGap.h10,
                // Definition
                if (card.definitionVi.isNotEmpty || card.definitionEn.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.translate_rounded, size: 16, color: AppColors.onSurface.withValues(alpha: 0.4)),
                      ),
                      AppGap.w8,
                      Expanded(
                        child: Text(
                          card.definitionVi.isNotEmpty ? card.definitionVi : card.definitionEn,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 15,
                            height: 1.55,
                            color: AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                // Example box
                if (card.exampleSentence.isNotEmpty) ...[
                  AppGap.h20,
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border(
                        left: BorderSide(color: AppColors.primaryContainer, width: 3.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                              color: AppColors.onSurface,
                            ),
                            children: _buildSpans(card.exampleSentence, card.word),
                          ),
                        ),
                        if (card.exampleTranslation.isNotEmpty) ...[
                          AppGap.h10,
                          Text(
                            card.exampleTranslation,
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
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

  List<TextSpan> _buildSpans(String sentence, String word) {
    final lower = sentence.toLowerCase();
    final idx = lower.indexOf(word.toLowerCase());
    if (idx == -1) return [TextSpan(text: '"$sentence"')];
    return [
      TextSpan(text: '"${sentence.substring(0, idx)}'),
      TextSpan(
        text: sentence.substring(idx, idx + word.length),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.normal,
        ),
      ),
      TextSpan(text: '${sentence.substring(idx + word.length)}"'),
    ];
  }
}

// ─── Rating Grid ─────────────────────────────────────────────────────────────

class StudySessionRatingGrid extends StatelessWidget {
  const StudySessionRatingGrid({
    super.key,
    required this.onRate,
    this.isLoading = false,
  });

  final void Function(CardRating) onRate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RatingBtn(
          icon: Icons.sentiment_very_dissatisfied_rounded,
          label: 'QUÊN',
          score: '(0)',
          bg: AppColors.surfaceContainerHigh,
          fg: AppColors.iconMuted,
          onTap: isLoading ? null : () => onRate(CardRating.forget),
        ),
        AppGap.w8,
        _RatingBtn(
          icon: Icons.sentiment_neutral_rounded,
          label: 'MỜ',
          score: '(2)',
          bg: const Color(0xFFF5EDE4),
          fg: AppColors.accentWarm,
          onTap: isLoading ? null : () => onRate(CardRating.vague),
        ),
        AppGap.w8,
        _RatingBtn(
          icon: Icons.sentiment_satisfied_alt_rounded,
          label: 'NHỚ',
          score: '(3)',
          bg: const Color(0xFFEEF0FF),
          fg: AppColors.primaryContainer,
          onTap: isLoading ? null : () => onRate(CardRating.remember),
        ),
        AppGap.w8,
        _RatingBtn(
          icon: Icons.sentiment_very_satisfied_rounded,
          label: 'TỐT',
          score: '(5)',
          bg: AppColors.primary,
          fg: AppColors.onPrimaryFixed,
          shadow: true,
          onTap: isLoading ? null : () => onRate(CardRating.mastered),
        ),
      ],
    );
  }
}

class _RatingBtn extends StatelessWidget {
  const _RatingBtn({
    required this.icon,
    required this.label,
    required this.score,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.shadow = false,
  });

  final IconData icon;
  final String label;
  final String score;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.55 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: shadow
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: fg, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  score,
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
