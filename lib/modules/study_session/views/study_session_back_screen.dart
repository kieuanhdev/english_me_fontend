import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
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
          child: _RatingGrid(onRate: controller.rateCard),
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
                  Text(
                    'Daily Session',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
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
                child: Obx(() => _FlashcardBack(card: controller.currentCard)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: '$current',
                style: const TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: '/$total',
                    style: const TextStyle(
                      fontFamily: 'BeVietnamPro',
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
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: const Color(0xFFC9CFFD)),
                FractionallySizedBox(
                  widthFactor: current / total,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF854d00), Color(0xFFD4761A)],
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

class _FlashcardBack extends StatelessWidget {
  const _FlashcardBack({required this.card});
  final StudyCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1A1C1C), blurRadius: 32, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Accent circle top-right
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDCBE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        card.partOfSpeech.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'BeVietnamPro',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFF2C1600),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.find<TtsService>().speak(card.word),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                        child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 22),
                      ),
                    ),
                  ],
                ),
                AppGap.h20,
                // Word
                Text(
                  card.word.toLowerCase(),
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                // Phonetic
                Text(
                  card.phonetic,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
                AppGap.h24,
                // Tonal divider
                Container(height: 1.5, color: AppColors.surfaceContainerLow),
                AppGap.h20,
                // Vietnamese meaning
                Text(
                  card.vietnameseMeaning,
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF643900),
                  ),
                ),
                AppGap.h10,
                // English definition
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.translate_rounded, size: 16, color: Color(0x661A1C1C)),
                    ),
                    AppGap.w8,
                    Expanded(
                      child: Text(
                        card.meaning,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 15,
                          height: 1.55,
                          color: AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                AppGap.h20,
                // Example box
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
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
                          children: _buildSpans(card.exampleEn, card.word),
                        ),
                      ),
                      AppGap.h10,
                      Text(
                        card.exampleVi,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
        style: const TextStyle(
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

class _RatingGrid extends StatelessWidget {
  const _RatingGrid({required this.onRate});
  final void Function(CardRating) onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RatingBtn(
          icon: Icons.sentiment_very_dissatisfied_rounded,
          label: 'QUÊN',
          score: '(0)',
          bg: AppColors.surfaceContainerHigh,
          fg: const Color(0xFF757684),
          onTap: () => onRate(CardRating.forget),
        ),
        AppGap.w8,
        _RatingBtn(
          icon: Icons.sentiment_neutral_rounded,
          label: 'MỜ',
          score: '(2)',
          bg: const Color(0xFFF5EDE4),
          fg: const Color(0xFF854d00),
          onTap: () => onRate(CardRating.vague),
        ),
        AppGap.w8,
        _RatingBtn(
          icon: Icons.sentiment_satisfied_alt_rounded,
          label: 'NHỚ',
          score: '(3)',
          bg: const Color(0xFFEEF0FF),
          fg: const Color(0xFF3F51B5),
          onTap: () => onRate(CardRating.remember),
        ),
        AppGap.w8,
        _RatingBtn(
          icon: Icons.sentiment_very_satisfied_rounded,
          label: 'TỐT',
          score: '(5)',
          bg: AppColors.primary,
          fg: Colors.white,
          shadow: true,
          onTap: () => onRate(CardRating.mastered),
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
  final VoidCallback onTap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: shadow
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10, fontWeight: FontWeight.w800, color: fg, letterSpacing: 0.5)),
              Text(score, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, fontWeight: FontWeight.w800, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

