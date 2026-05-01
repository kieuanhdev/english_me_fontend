import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/vocab/vocab_learning_screen.dart';

class PlacementQuestionScreen extends StatefulWidget {
  const PlacementQuestionScreen({super.key});

  @override
  State<PlacementQuestionScreen> createState() => _PlacementQuestionScreenState();
}

class _PlacementQuestionScreenState extends State<PlacementQuestionScreen> {
  int _questionIndex = 0;
  String? _selectedId;
  bool _submitted = false;

  final List<_QuestionModel> _questions = const [
    _QuestionModel(
      skill: 'Ngữ pháp',
      prompt: 'She ___ to school every morning.',
      options: [
        _OptionModel(id: 'A', text: 'go'),
        _OptionModel(id: 'B', text: 'goes'),
        _OptionModel(id: 'C', text: 'going'),
        _OptionModel(id: 'D', text: 'went'),
      ],
      correctId: 'B',
      progress: 0.12,
    ),
    _QuestionModel(
      skill: 'Từ vựng',
      prompt: 'Từ "diligent" có nghĩa là gì?',
      options: [
        _OptionModel(id: 'A', text: 'Lười biếng'),
        _OptionModel(id: 'B', text: 'Chăm chỉ'),
        _OptionModel(id: 'C', text: 'Thông minh'),
        _OptionModel(id: 'D', text: 'Tò mò'),
      ],
      correctId: 'B',
      progress: 0.38,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final _QuestionModel question = _questions[_questionIndex];
    final bool answeredCorrect = _submitted && _selectedId == question.correctId;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuestionTopBar(
                progress: question.progress,
                lives: 5,
                onClose: () => Navigator.of(context).pop(),
              ),
              AppGap.h24,
              _SkillChip(skill: question.skill),
              AppGap.h14,
              Text(
                'Chọn đáp án đúng:',
                style: AppTypography.displayLarge.copyWith(fontSize: 24),
              ),
              AppGap.h16,
              _PromptCard(text: question.prompt),
              AppGap.h16,
              ...question.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnswerTile(
                    option: option,
                    selected: _selectedId == option.id,
                    submitted: _submitted,
                    isCorrect: option.id == question.correctId,
                    onTap: () {
                      if (_submitted) return;
                      setState(() => _selectedId = option.id);
                    },
                  ),
                ),
              ),
              AppGap.h14,
              if (!_submitted)
                AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _selectedId == null
                      ? null
                      : () => setState(() => _submitted = true),
                  variant: AppButtonVariant.primary,
                  textStyle: AppTypography.labelMedium.copyWith(fontSize: 18),
                )
              else
                _ResultPanel(
                  correct: answeredCorrect,
                  correctAnswerText: question.options
                      .firstWhere((e) => e.id == question.correctId)
                      .text,
                  onContinue: _nextQuestion,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextQuestion() {
    if (_questionIndex >= _questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const VocabLearningScreen(),
        ),
      );
      return;
    }

    setState(() {
      _questionIndex += 1;
      _selectedId = null;
      _submitted = false;
    });
  }
}

class _QuestionTopBar extends StatelessWidget {
  const _QuestionTopBar({
    required this.progress,
    required this.lives,
    required this.onClose,
  });

  final double progress;
  final int lives;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: AppColors.iconMuted, size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
        ),
        AppGap.w10,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.secondaryContainer,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ),
        AppGap.w12,
        const Icon(Icons.favorite, color: AppColors.danger, size: 22),
        const SizedBox(width: 4),
        Text(
          '$lives',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.danger,
            fontWeight: FontWeight.w800,
            fontSize: 24,
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
        borderRadius: BorderRadius.circular(999),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
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

  final _OptionModel option;
  final bool selected;
  final bool submitted;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool wrongSelected = submitted && selected && !isCorrect;
    final bool correctState = submitted && isCorrect;

    Color border = AppColors.outlineVariant;
    Color bg = AppColors.surface;
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border.withValues(alpha: 0.5), width: 2),
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
    required this.correctAnswerText,
    required this.onContinue,
  });

  final bool correct;
  final String correctAnswerText;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final Color bg = correct ? AppColors.successPanel : AppColors.dangerPanel;
    final Color iconColor = correct ? AppColors.success : AppColors.danger;
    final Color titleColor = correct ? AppColors.successDark : AppColors.dangerDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                child: Icon(
                  correct ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              AppGap.w10,
              Text(
                correct ? 'Chính xác!' : 'Chưa đúng',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 30 * 0.7,
                  color: titleColor,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            AppGap.h8,
            Text(
              'Đáp án đúng: $correctAnswerText',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.dangerDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
          AppGap.h12,
          _ContinueButton(correct: correct, onPressed: onContinue),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.correct, required this.onPressed});

  final bool correct;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color mainColor = correct ? AppColors.success : AppColors.danger;
    final Color shadowColor = correct ? AppColors.successShadow : AppColors.dangerDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: shadowColor, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          'TIẾP TỤC',
          style: AppTypography.labelMedium.copyWith(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _QuestionModel {
  const _QuestionModel({
    required this.skill,
    required this.prompt,
    required this.options,
    required this.correctId,
    required this.progress,
  });

  final String skill;
  final String prompt;
  final List<_OptionModel> options;
  final String correctId;
  final double progress;
}

class _OptionModel {
  const _OptionModel({required this.id, required this.text});

  final String id;
  final String text;
}
