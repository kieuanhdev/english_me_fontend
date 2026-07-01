import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/exercise/controllers/exercise_controller.dart';
import 'package:englishme/modules/exercise/models/exercise_model.dart';
import 'package:englishme/theme/app_theme.dart';

class ExerciseQuizScreen extends GetView<ExerciseController> {
  const ExerciseQuizScreen({super.key});

  ApiState _mapState(ExerciseState s, ExerciseController c) {
    switch (s) {
      case ExerciseState.idle:
      case ExerciseState.loading:
      case ExerciseState.submitting:
        return ApiState.loading;
      case ExerciseState.error:
        return ApiState.error;
      case ExerciseState.playing:
      case ExerciseState.finished:
        return c.currentExercise == null ? ApiState.empty : ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _mapState(controller.state.value, controller),
            errorMessage: controller.errorMessage.value.isEmpty
                ? null
                : controller.errorMessage.value,
            emptyMessage: 'Chưa có câu hỏi cho bài tập này.',
            onRetry: controller.retrySession,
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QuizAppBar(onClose: controller.closeExercise),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    () => _ProgressHeader(
                      current: controller.currentIndex.value + 1,
                      total: controller.questions.length,
                      correctCount: controller.correctCount,
                    ),
                  ),
                ),
                AppGap.h20,
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => _QuizBody(
                        question: controller.currentExercise!,
                        selectedAnswer: controller.selectedAnswer.value,
                        isRevealed: controller.isAnswerRevealed.value,
                        onSelectAnswer: controller.selectAnswer,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => _BottomAction(
                    selectedAnswer: controller.selectedAnswer.value,
                    isRevealed: controller.isAnswerRevealed.value,
                    isLast: controller.isLastQuestion,
                    onConfirm: controller.confirmAnswer,
                    onNext: controller.nextQuestion,
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

class _QuizAppBar extends StatelessWidget {
  const _QuizAppBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          AppCloseButton(onPressed: onClose),
          AppGap.w8,
          Text(
            'Luyện tập',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Header ──────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.correctCount,
  });
  final int current;
  final int total;
  final int correctCount;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current - 1) / total : 0.0;
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
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  '$correctCount đúng',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
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
                Container(color: AppColors.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
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

// ─── Quiz Body ────────────────────────────────────────────────────────────────

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.question,
    required this.selectedAnswer,
    required this.isRevealed,
    required this.onSelectAnswer,
  });

  final ExerciseQuestion question;
  final String? selectedAnswer;
  final bool isRevealed;
  final ValueChanged<String> onSelectAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category chip
        Row(
          children: [
            _CategoryChip(category: question.category),
            AppGap.w8,
            _DifficultyChip(difficulty: question.difficulty),
          ],
        ),
        AppGap.h18,
        // Passage (reading) — đoạn văn đọc hiểu phía trên câu hỏi.
        if (question.passage != null && question.passage!.trim().isNotEmpty) ...[
          _PassageCard(passage: question.passage!.trim()),
          AppGap.h16,
        ],
        // Question card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            question.question,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        AppGap.h20,
        // Options
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final label = String.fromCharCode(65 + index); // A, B, C, D
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              label: label,
              text: option,
              isSelected: selectedAnswer == option,
              isRevealed: isRevealed,
              isCorrect: option == question.correctAnswer,
              onTap: isRevealed ? null : () => onSelectAnswer(option),
            ),
          );
        }),
        // Explanation (after reveal)
        if (isRevealed && question.explanation != null) ...[
          AppGap.h12,
          _ExplanationCard(explanation: question.explanation!),
        ],
        AppGap.h20,
      ],
    );
  }
}

// ─── Option Tile ──────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isRevealed,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool isSelected;
  final bool isRevealed;
  final bool isCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    final Color labelBg;
    final Color labelFg;

    if (!isRevealed) {
      borderColor = isSelected ? AppColors.primary : AppColors.outlineVariant;
      bgColor = isSelected
          ? AppColors.chipHighlightBg
          : AppColors.surfaceContainerLowest;
      labelBg = isSelected ? AppColors.primary : AppColors.surfaceContainerHigh;
      labelFg = isSelected ? AppColors.onPrimaryFixed : AppColors.iconMuted;
    } else if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.successPanel;
      labelBg = AppColors.success;
      labelFg = AppColors.onPrimaryFixed;
    } else if (isSelected && !isCorrect) {
      borderColor = AppColors.danger;
      bgColor = AppColors.dangerPanel;
      labelBg = AppColors.danger;
      labelFg = AppColors.onPrimaryFixed;
    } else {
      borderColor = AppColors.outlineVariant;
      bgColor = AppColors.surfaceContainerLowest;
      labelBg = AppColors.surfaceContainerHigh;
      labelFg = AppColors.iconMuted;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: labelBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: labelFg,
                ),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyLarge.copyWith(fontSize: 14),
              ),
            ),
            if (isRevealed)
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : (isSelected ? Icons.cancel_rounded : null),
                color: isCorrect ? AppColors.success : AppColors.danger,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Passage Card (reading) ───────────────────────────────────────────────────

class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.passage});
  final String passage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded,
                  size: 14, color: AppColors.tertiary),
              const SizedBox(width: 6),
              Text(
                'Đoạn văn',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          AppGap.h8,
          Text(
            passage,
            style: AppTypography.bodyLarge.copyWith(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Category & Difficulty Chips ──────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final ExerciseCategory category;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (category) {
      ExerciseCategory.vocabulary => (
          'Từ vựng',
          AppColors.skillVocabulary,
          Icons.style_rounded
        ),
      ExerciseCategory.grammar => (
          'Ngữ pháp',
          AppColors.skillGrammar,
          Icons.menu_book_rounded
        ),
      ExerciseCategory.reading => (
          'Đọc hiểu',
          AppColors.tertiary,
          Icons.chrome_reader_mode_rounded
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});
  final ExerciseDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      ExerciseDifficulty.easy => ('Dễ', AppColors.success),
      ExerciseDifficulty.medium => ('Trung bình', AppColors.skillVocabulary),
      ExerciseDifficulty.hard => ('Khó', AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Explanation Card ─────────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.explanation});
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
          AppGap.w8,
          Expanded(
            child: Text(
              explanation,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Action ────────────────────────────────────────────────────────────

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.selectedAnswer,
    required this.isRevealed,
    required this.isLast,
    required this.onConfirm,
    required this.onNext,
  });

  final String? selectedAnswer;
  final bool isRevealed;
  final bool isLast;
  final VoidCallback onConfirm;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isRevealed
              ? _PrimaryButton(
                  key: const ValueKey('next'),
                  label: isLast ? 'Xem kết quả' : 'Câu tiếp theo',
                  icon: isLast
                      ? Icons.emoji_events_rounded
                      : Icons.arrow_forward_rounded,
                  enabled: true,
                  onTap: onNext,
                )
              : _PrimaryButton(
                  key: const ValueKey('confirm'),
                  label: 'Kiểm tra',
                  icon: Icons.check_rounded,
                  enabled: selectedAnswer != null,
                  onTap: selectedAnswer != null ? onConfirm : null,
                ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      isTranslate: false,
      onPressed: enabled ? onTap : null,
      gradient: true,
      radius: AppRadius.pill,
      trailing: Icon(icon, size: 18),
    );
  }
}
