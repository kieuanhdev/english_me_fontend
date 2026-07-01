import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/test/controllers/test_controller.dart';
import 'package:englishme/modules/test/models/test_model.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';

class TestQuestionScreen extends GetView<TestController> {
  const TestQuestionScreen({super.key});

  ApiState _mapState(TestState s, TestController c) {
    switch (s) {
      case TestState.idle:
      case TestState.loading:
      case TestState.submitting:
        return ApiState.loading;
      case TestState.error:
        return ApiState.error;
      case TestState.playing:
      case TestState.finished:
        return c.currentQuestion == null ? ApiState.empty : ApiState.success;
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
            emptyMessage: T.emptyTestQuestions.tr,
            onRetry: controller.retryTest,
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TestAppBar(controller: controller),
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
                      () => _QuestionBody(
                        question: controller.currentQuestion!,
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

class _TestAppBar extends StatelessWidget {
  const _TestAppBar({required this.controller});
  final TestController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          AppCloseButton(
            onPressed: () => _showExitDialog(context, controller),
          ),
          AppGap.w8,
          Expanded(
            child: Obx(
              () => Text(
                '${controller.selectedTopic.value?.label ?? ''} · ${controller.selectedLevel.value?.label ?? ''}',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Obx(
            () => _TimerChip(
              display: controller.timerDisplay,
              isWarning: controller.isTimerWarning,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, TestController ctrl) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(T.testExitDialogTitle.tr),
        content: Text(T.testExitDialogContent.tr),
        actions: [
          AppButton(
            label: T.testContinue,
            onPressed: () => Navigator.pop(ctx),
            variant: AppButtonVariant.text,
            expand: false,
            height: 44,
          ),
          AppButton(
            label: T.testExit,
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.closeTest();
            },
            variant: AppButtonVariant.dangerText,
            expand: false,
            height: 44,
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.display, required this.isWarning});
  final String display;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.danger : AppColors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            display,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
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

// ─── Question Body ────────────────────────────────────────────────────────────

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.question,
    required this.selectedAnswer,
    required this.isRevealed,
    required this.onSelectAnswer,
  });

  final TestQuestion question;
  final String? selectedAnswer;
  final bool isRevealed;
  final ValueChanged<String> onSelectAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _TopicChip(topic: question.topic),
            AppGap.w8,
            _LevelChip(level: question.level),
          ],
        ),
        AppGap.h18,
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
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        AppGap.h20,
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final label = String.fromCharCode(65 + index);
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

// ─── Chips ────────────────────────────────────────────────────────────────────

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.topic});
  final TestTopic topic;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (topic) {
      TestTopic.grammar => (AppColors.skillGrammar, Icons.menu_book_rounded),
      TestTopic.vocabulary => (AppColors.skillVocabulary, Icons.style_rounded),
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
            topic.label,
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

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});
  final TestLevel level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      TestLevel.a1 => const Color(0xFF4CAF50),
      TestLevel.a2 => const Color(0xFF8BC34A),
      TestLevel.b1 => const Color(0xFFFFB74D),
      TestLevel.b2 => const Color(0xFFFF7043),
      TestLevel.c1 => const Color(0xFFE53935),
      TestLevel.c2 => const Color(0xFF9C27B0),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        level.label,
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
                  label: isLast ? 'Nộp bài' : 'Câu tiếp theo',
                  icon: isLast
                      ? Icons.send_rounded
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
      leading: Icon(
        icon,
        size: 18,
        color: enabled ? AppColors.onPrimaryFixed : AppColors.iconMuted,
      ),
      textStyle: AppTypography.headlineMedium.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onPrimaryFixed,
      ),
    );
  }
}
