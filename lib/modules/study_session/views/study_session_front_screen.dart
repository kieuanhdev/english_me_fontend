import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/modules/study_session/views/study_session_back_screen.dart';
import 'package:englishme/theme/app_theme.dart';

class StudySessionFrontScreen extends GetView<StudySessionController> {
  const StudySessionFrontScreen({super.key});

  ApiState _mapState(StudySessionController c) {
    if (c.isLoading.value) return ApiState.loading;
    if (c.errorMessage.isNotEmpty) return ApiState.error;
    if (c.cards.isEmpty) return ApiState.empty;
    return ApiState.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: Obx(
        () => controller.isCardFlipped.value
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: StudySessionRatingGrid(
                    onRate: controller.rateCard,
                    isLoading: controller.isReviewing.value,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _mapState(controller),
            errorMessage: controller.errorMessage.value.isEmpty
                ? null
                : controller.errorMessage.value,
            emptyMessage: 'Không có từ nào để học trong bộ thẻ này.',
            emptyIcon: Icons.style_outlined,
            onRetry: controller.retryLoad,
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SessionAppBar(
                  title: controller.deskTitle,
                  onClose: controller.closeSession,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => _ProgressSection(
                        current: controller.currentIndex.value + 1,
                        total: controller.totalCards,
                      )),
                ),
                AppGap.h16,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => controller.isCardFlipped.value
                          ? SingleChildScrollView(
                              child: StudySessionFlashcardBack(
                                card: controller.currentCard,
                                onSpeak: controller.speak,
                              ),
                            )
                          : _FlashcardFront(
                              card: controller.currentCard,
                              onFlip: controller.flipCard,
                              onSpeak: controller.speak,
                            ),
                    ),
                  ),
                ),
                AppGap.h16,
                Obx(
                  () => controller.isCardFlipped.value
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: _TopicTip(topic: controller.currentCard.topicId),
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _SessionAppBar extends StatelessWidget {
  const _SessionAppBar({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 22),
            color: AppColors.primary,
          ),
          Text(
            title.isNotEmpty ? title : 'Daily Session',
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

// ─── Flashcard Front ─────────────────────────────────────────────────────────

class _FlashcardFront extends StatelessWidget {
  const _FlashcardFront({
    required this.card,
    required this.onFlip,
    required this.onSpeak,
  });
  final VocabWord card;
  final VoidCallback onFlip;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final posLabel = card.pos.isNotEmpty ? card.pos.first : '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 32, offset: Offset(0, 8)),
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
                Icon(Icons.menu_book_rounded, size: 32, color: AppColors.levelCFg),
                AppGap.h20,
                Text(
                  card.word,
                  style: AppTypography.displayLarge.copyWith(
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
                    if (posLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          posLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    AppGap.w8,
                    GestureDetector(
                      onTap: onSpeak,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          size: 17,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                if (card.ipa.isNotEmpty) ...[
                  AppGap.h8,
                  Text(
                    card.ipa,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lật thẻ',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryFixed,
                          ),
                        ),
                        AppGap.w8,
                        Icon(Icons.refresh_rounded, color: AppColors.onPrimaryFixed, size: 20),
                      ],
                    ),
                  ),
                ),
                AppGap.h12,
                Text(
                  'Nhấn để xem nghĩa của từ',
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

// ─── Topic Tip ───────────────────────────────────────────────────────────────

class _TopicTip extends StatelessWidget {
  const _TopicTip({required this.topic});
  final String topic;

  @override
  Widget build(BuildContext context) {
    if (topic.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow,
            ),
            child: Icon(Icons.tag_rounded, color: AppColors.primary, size: 19),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chủ đề',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
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
