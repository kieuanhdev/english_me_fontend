import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/theme/app_theme.dart';

class StudySessionFrontScreen extends GetView<StudySessionController> {
  const StudySessionFrontScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                  () => _FlashcardFront(
                    card: controller.currentCard,
                    onFlip: controller.flipCard,
                  ),
                ),
              ),
            ),
            AppGap.h16,
            // Scholar tip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Obx(() => _ScholarTip(tip: controller.currentCard.scholarTip)),
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
              'SESSION PROGRESS',
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

// ─── Flashcard Front ─────────────────────────────────────────────────────────

class _FlashcardFront extends StatelessWidget {
  const _FlashcardFront({required this.card, required this.onFlip});
  final StudyCard card;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1C1C),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Word area
            Column(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 32,
                  color: Color(0xFF643900),
                ),
                AppGap.h20,
                Text(
                  card.word,
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppGap.h14,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.partOfSpeech,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    AppGap.w8,
                    GestureDetector(
                      onTap: () => Get.find<TtsService>().speak(card.word),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 17,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Flip button
            Column(
              children: [
                GestureDetector(
                  onTap: onFlip,
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Lật thẻ',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        AppGap.w8,
                        const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                AppGap.h12,
                Text(
                  'Click on the card or press Space to flip',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 12,
                    color: AppColors.iconMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scholar Tip ─────────────────────────────────────────────────────────────

class _ScholarTip extends StatelessWidget {
  const _ScholarTip({required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x061A1C1C), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 19),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Scholar's Tip",
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.onSurface.withValues(alpha: 0.65),
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

