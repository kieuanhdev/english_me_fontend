import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/test/controllers/test_controller.dart';
import 'package:englishme/modules/test/models/test_model.dart';
import 'package:englishme/theme/app_theme.dart';

class TestQuestionScreen extends GetView<TestController> {
  const TestQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          if (controller.state.value == TestState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.state.value == TestState.error) {
            return _ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.retryTest,
            );
          }
          final q = controller.currentQuestion;
          if (q == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TestAppBar(controller: controller),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => _ProgressHeader(
                      current: controller.currentIndex.value + 1,
                      total: controller.questions.length,
                      correctCount: controller.correctCount,
                    )),
              ),
              AppGap.h20,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => _QuestionBody(
                        question: controller.currentQuestion!,
                        selectedAnswer: controller.selectedAnswer.value,
                        isRevealed: controller.isAnswerRevealed.value,
                        onSelectAnswer: controller.selectAnswer,
                      )),
                ),
              ),
              Obx(() => _BottomAction(
                    selectedAnswer: controller.selectedAnswer.value,
                    isRevealed: controller.isAnswerRevealed.value,
                    isLast: controller.isLastQuestion,
                    onConfirm: controller.confirmAnswer,
                    onNext: controller.nextQuestion,
                  )),
            ],
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
          IconButton(
            onPressed: () => _showExitDialog(context, controller),
            icon: const Icon(Icons.close_rounded, size: 22),
            color: AppColors.primary,
          ),
          Expanded(
            child: Obx(() => Text(
                  '${controller.selectedTopic.value?.label ?? ''} · ${controller.selectedLevel.value?.label ?? ''}',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                )),
          ),
          Obx(() => _TimerChip(
                display: controller.timerDisplay,
                isWarning: controller.isTimerWarning,
              )),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, TestController ctrl) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thoát bài kiểm tra?'),
        content: const Text('Tiến trình sẽ không được lưu. Bạn có chắc muốn thoát?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục làm'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.closeTest();
            },
            child: Text('Thoát', style: TextStyle(color: AppColors.danger)),
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            display,
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
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
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: '/$total',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
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
                Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  '$correctCount đúng',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
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
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: AppColors.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient),
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: const [
              BoxShadow(color: Color(0x0A1A1C1C), blurRadius: 16, offset: Offset(0, 4)),
            ],
          ),
          child: Text(
            question.question,
            style: const TextStyle(
              fontFamily: 'BeVietnamPro',
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
      bgColor = isSelected ? AppColors.chipHighlightBg : AppColors.surfaceContainerLowest;
      labelBg = isSelected ? AppColors.primary : AppColors.surfaceContainerHigh;
      labelFg = isSelected ? Colors.white : AppColors.iconMuted;
    } else if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.successPanel;
      labelBg = AppColors.success;
      labelFg = Colors.white;
    } else if (isSelected && !isCorrect) {
      borderColor = AppColors.danger;
      bgColor = AppColors.dangerPanel;
      labelBg = AppColors.danger;
      labelFg = Colors.white;
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
          borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
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
      TestTopic.pronunciation => (AppColors.skillListening, Icons.record_voice_over_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            topic.label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
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
        borderRadius: BorderRadius.circular(16),
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
                  icon: isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.primaryGradient : null,
          color: enabled ? null : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : AppColors.iconMuted,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: enabled ? Colors.white : AppColors.iconMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.iconMuted),
            AppGap.h16,
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            AppGap.h20,
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
