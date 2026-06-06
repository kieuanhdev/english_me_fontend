import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/placement_test/models/placement_test_models.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:get/get.dart';

class PlacementQuestionScreen extends GetView<PlacementTestController> {
  const PlacementQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          final state = controller.state.value;

          if (state == PlacementTestState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = controller.currentQuestion;
          if (question == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestionTopBar(
                  progress: controller.progress,
                  answeredCount: controller.currentIndex.value,
                  totalQuestions: controller.questions.length,
                  onClose: () => Get.back(),
                ),
                AppGap.h12,
                const _CapBanner(),
                AppGap.h16,
                _SkillChip(skill: question.skillCategory),
                AppGap.h14,
                Text(
                  'Chọn đáp án đúng:',
                  style: AppTypography.displayLarge.copyWith(fontSize: 24),
                ),
                AppGap.h16,
                _PromptCard(text: question.question),
                AppGap.h16,
                ...question.optionList.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Obx(
                      () => _AnswerTile(
                        option: option,
                        selected: controller.selectedAnswer.value == option.id,
                        submitted: controller.isAnswered,
                        isCorrect:
                            controller.answerResponse.value?.correctAnswer ==
                            option.id,
                        onTap: () => controller.selectAnswer(option.id),
                      ),
                    ),
                  ),
                ),
                AppGap.h14,
                Obx(() {
                  if (!controller.isAnswered) {
                    return AppButton(
                      label: state == PlacementTestState.submitting
                          ? 'ĐANG GỬI...'
                          : 'KIỂM TRA',
                      onPressed:
                          (controller.selectedAnswer.value == null ||
                              state == PlacementTestState.submitting)
                          ? null
                          : controller.submitAnswer,
                      textStyle: AppTypography.labelMedium.copyWith(
                        fontSize: 18,
                      ),
                    );
                  }
                  final response = controller.answerResponse.value!;
                  return _ResultPanel(
                    correct: response.isCorrect,
                    correctAnswer: response.correctAnswer,
                    correctAnswerText:
                        question.options[response.correctAnswer] ?? '',
                    explanation: response.explanation,
                    onContinue: controller.nextQuestion,
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Banner nhỏ cố định nhắc giới hạn B2 trong suốt quá trình làm bài.
class _CapBanner extends StatelessWidget {
  const _CapBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.primaryContainer),
          AppGap.w8,
          Expanded(
            child: Text(
              'Bài kiểm tra đầu vào • Xác định trình độ tối đa tới B2',
              style: AppTypography.labelMedium.copyWith(
                fontSize: 12,
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTopBar extends StatelessWidget {
  const _QuestionTopBar({
    required this.progress,
    required this.answeredCount,
    required this.totalQuestions,
    required this.onClose,
  });

  final double progress;
  final int answeredCount;
  final int totalQuestions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: AppColors.iconMuted, size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
        ),
        AppGap.w10,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.secondaryContainer,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
        AppGap.w12,
        Text(
          '$answeredCount/$totalQuestions',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});

  final String skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        skill,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.primaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
        text,
        textAlign: TextAlign.center,
        style: AppTypography.displayLarge.copyWith(fontSize: 22, height: 1.2),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.option,
    required this.selected,
    required this.submitted,
    required this.isCorrect,
    required this.onTap,
  });

  final QuestionOptionModel option;
  final bool selected;
  final bool submitted;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool wrongSelected = submitted && selected && !isCorrect;
    final bool correctState = submitted && isCorrect;

    Color border = AppColors.outlineVariant;
    Color bg = AppColors.surfaceContainerLowest;
    Color textColor = AppColors.onSurface;

    if (!submitted && selected) {
      border = AppColors.primary;
      bg = AppColors.primarySoftSelected;
      textColor = AppColors.primaryContainer;
    }
    if (correctState) {
      border = AppColors.success;
      bg = AppColors.successSoft;
      textColor = AppColors.successDark;
    }
    if (wrongSelected) {
      border = AppColors.danger;
      bg = AppColors.dangerSoft;
      textColor = AppColors.dangerDark;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: border,
            width: selected || submitted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: border.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  option.id,
                  style: AppTypography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Text(
                option.text,
                style: AppTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            if (submitted && (wrongSelected || correctState))
              Icon(
                correctState ? Icons.check : Icons.close,
                color: correctState ? AppColors.success : AppColors.danger,
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.correct,
    required this.correctAnswer,
    required this.correctAnswerText,
    required this.explanation,
    required this.onContinue,
  });

  final bool correct;
  final String correctAnswer;
  final String correctAnswerText;
  final String explanation;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final Color bg = correct ? AppColors.successPanel : AppColors.dangerPanel;
    final Color iconColor = correct ? AppColors.success : AppColors.danger;
    final Color titleColor = correct
        ? AppColors.successDark
        : AppColors.dangerDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correct ? Icons.check : Icons.close,
                  color: AppColors.onPrimaryFixed,
                  size: 22,
                ),
              ),
              AppGap.w10,
              Text(
                correct ? 'Chính xác!' : 'Chưa đúng',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 21,
                  color: titleColor,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            AppGap.h8,
            Text(
              'Đáp án đúng: $correctAnswer. $correctAnswerText',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.dangerDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
          if (explanation.isNotEmpty) ...[
            AppGap.h6,
            Text(
              explanation,
              style: AppTypography.bodyLarge.copyWith(
                color: titleColor.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          AppGap.h12,
          _ContinueButton(onPressed: onContinue),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'TIẾP TỤC',
      isTranslate: false,
      onPressed: onPressed,
      textStyle: AppTypography.labelMedium.copyWith(
        fontSize: 18,
        color: AppColors.onPrimaryFixed,
      ),
      leading: Icon(
        Icons.arrow_forward_rounded,
        size: 20,
        color: AppColors.onPrimaryFixed,
      ),
    );
  }
}
