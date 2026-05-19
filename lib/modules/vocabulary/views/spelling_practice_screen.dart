import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/vocabulary/controllers/vocabulary_controller.dart';
import 'package:englishme/modules/vocabulary/models/vocabulary_model.dart';
import 'package:englishme/theme/app_theme.dart';

class SpellingPracticeScreen extends GetView<VocabularyController> {
  const SpellingPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Obx(() {
                  final word = controller.currentSpellingWord;
                  if (word == null) return const SizedBox.shrink();
                  final state = controller.spellingState.value;
                  return Column(
                    children: [
                      _WordPromptCard(word: word, state: state),
                      AppGap.h28,
                      _InputSection(state: state),
                      AppGap.h20,
                      if (state == SpellingState.correct || state == SpellingState.wrong)
                        _FeedbackSection(word: word, state: state),
                    ],
                  );
                }),
              ),
            ),
            _BottomBar(),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Header ──────────────────────────────────────────────────────────

class _ProgressHeader extends GetView<VocabularyController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Obx(() {
        final current = controller.spellingIndex.value + 1;
        final total = controller.spellingWords.length;
        final progress = total > 0 ? current / total : 0.0;
        return Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.close_rounded, size: 20, color: AppColors.onSurface),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Luyện đánh vần',
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$current / $total',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: AppColors.outlineVariant,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Word Prompt Card ─────────────────────────────────────────────────────────

class _WordPromptCard extends StatelessWidget {
  const _WordPromptCard({required this.word, required this.state});
  final VocabularyWord word;
  final SpellingState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.volume_up_rounded, size: 32, color: AppColors.primary),
          ),
          AppGap.h16,
          Text(
            'Nghe và gõ từ bạn nghe được',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppGap.h12,
          Text(
            word.definitionVi,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppGap.h8,
          Text(
            word.pronunciation,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          if (state == SpellingState.correct || state == SpellingState.wrong) ...[
            AppGap.h16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                word.word,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: state == SpellingState.correct
                      ? AppColors.success
                      : AppColors.danger,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Input Section ────────────────────────────────────────────────────────────

class _InputSection extends GetView<VocabularyController> {
  const _InputSection({required this.state});
  final SpellingState state;

  bool get _enabled => state == SpellingState.typing;

  @override
  Widget build(BuildContext context) {
    final isCorrect = state == SpellingState.correct;
    final isWrong = state == SpellingState.wrong;
    final isDone = isCorrect || isWrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gõ từ vào đây:',
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        AppGap.h8,
        TextField(
          controller: controller.spellingController,
          enabled: _enabled,
          onChanged: controller.onSpellingInputChange,
          onSubmitted: (_) {
            if (_enabled) controller.submitSpelling();
          },
          textCapitalization: TextCapitalization.none,
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDone
                ? (isCorrect ? AppColors.successDark : AppColors.dangerDark)
                : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Nhập từ tiếng Anh...',
            hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.iconMuted),
            filled: true,
            fillColor: isDone
                ? (isCorrect ? AppColors.successPanel : AppColors.dangerPanel)
                : AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: isCorrect
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.danger.withValues(alpha: 0.4),
              ),
            ),
            suffixIcon: isDone
                ? Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.danger,
                  )
                : null,
          ),
          autofocus: true,
        ),
        if (_enabled) ...[
          AppGap.h16,
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: controller.submitSpelling,
              child: Text(
                'Kiểm tra',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Feedback Section ─────────────────────────────────────────────────────────

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.word, required this.state});
  final VocabularyWord word;
  final SpellingState state;

  @override
  Widget build(BuildContext context) {
    final isCorrect = state == SpellingState.correct;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.successPanel : AppColors.dangerPanel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: isCorrect ? AppColors.successDark : AppColors.dangerDark,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Chính xác!' : 'Chưa đúng',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? AppColors.successDark : AppColors.dangerDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            word.exampleSentence,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.exampleTranslation,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends GetView<VocabularyController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.spellingState.value;
      final isDone = state == SpellingState.correct || state == SpellingState.wrong;
      if (!isDone) return const SizedBox.shrink();

      final isLast = controller.spellingIndex.value >= controller.spellingWords.length - 1;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: controller.nextSpellingWord,
              icon: Icon(
                isLast ? Icons.bar_chart_rounded : Icons.arrow_forward_rounded,
                size: 20,
              ),
              label: Text(
                isLast ? 'Xem kết quả' : 'Từ tiếp theo',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
