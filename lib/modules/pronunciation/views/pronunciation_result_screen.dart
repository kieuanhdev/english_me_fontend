import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/data/models/pronunciation_models.dart';
import 'package:englishme/modules/pronunciation/controllers/pronunciation_controller.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PronunciationResultScreen extends StatelessWidget {
  const PronunciationResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PronunciationController>();
    final feedback = ctrl.feedback.value;
    final exercise = ctrl.selectedExercise.value;

    if (feedback == null || exercise == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                AppGap.h16,
                Text(
                  'Không có dữ liệu kết quả.',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                AppGap.h16,
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: () => Get.back()),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Kết quả phát âm',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              AppGap.h24,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ScoreHeader(feedback: feedback),
                      AppGap.h24,
                      _ScoreBreakdown(feedback: feedback),
                      AppGap.h24,
                      _TranscriptionCard(
                        expected: exercise.text,
                        actual: feedback.transcription,
                      ),
                      if (feedback.errors.isNotEmpty) ...[
                        AppGap.h24,
                        _ErrorList(errors: feedback.errors),
                      ],
                      if (feedback.overallComment != null) ...[
                        AppGap.h24,
                        _CommentCard(comment: feedback.overallComment!),
                      ],
                      AppGap.h32,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.feedback});

  final PronunciationFeedback feedback;

  Color _scoreColor() {
    if (feedback.score >= 80) return AppColors.success;
    if (feedback.score >= 60) return AppColors.tertiary;
    return AppColors.danger;
  }

  String _scoreLabel() {
    if (feedback.score >= 90) return 'Xuất sắc!';
    if (feedback.score >= 80) return 'Tốt!';
    if (feedback.score >= 60) return 'Khá';
    return 'Cần cải thiện';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: feedback.score / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(_scoreColor()),
                ),
                Text(
                  '${feedback.score.round()}',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 28,
                    color: _scoreColor(),
                  ),
                ),
              ],
            ),
          ),
          AppGap.h16,
          Text(
            _scoreLabel(),
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 22,
              color: _scoreColor(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.feedback});

  final PronunciationFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết điểm',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h16,
          _ScoreBar(label: 'Độ chính xác', value: feedback.accuracy / 100),
          AppGap.h12,
          _ScoreBar(label: 'Độ trôi chảy', value: feedback.fluency / 100),
          AppGap.h12,
          _ScoreBar(label: 'Độ hoàn chỉnh', value: feedback.completeness / 100),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});

  final String label;
  final double value;

  Color _barColor() {
    if (value >= 0.8) return AppColors.success;
    if (value >= 0.6) return AppColors.tertiary;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body.copyWith(fontSize: 14)),
            Text(
              '${(value * 100).round()}%',
              style: AppTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _barColor(),
              ),
            ),
          ],
        ),
        AppGap.h8,
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
            ),
          ),
        ),
      ],
    );
  }
}

class _TranscriptionCard extends StatelessWidget {
  const _TranscriptionCard({required this.expected, required this.actual});

  final String expected;
  final String actual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'So sánh phiên âm',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h16,
          _TranscriptionRow(
            label: 'Mẫu',
            text: expected,
            color: AppColors.success,
          ),
          AppGap.h12,
          _TranscriptionRow(
            label: 'Bạn đọc',
            text: actual.isEmpty ? 'Không nhận dạng được' : actual,
            color: actual.isEmpty ? AppColors.textSecondary : AppColors.tertiary,
          ),
        ],
      ),
    );
  }
}

class _TranscriptionRow extends StatelessWidget {
  const _TranscriptionRow({
    required this.label,
    required this.text,
    required this.color,
  });

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        AppGap.w12,
        Expanded(
          child: Text(
            text,
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }
}

class _ErrorList extends StatelessWidget {
  const _ErrorList({required this.errors});

  final List<PronunciationError> errors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: AppColors.danger),
              AppGap.w8,
              Text(
                '${errors.length} lỗi phát âm',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          AppGap.h16,
          ...errors.map((e) => _ErrorItem(error: e)),
        ],
      ),
    );
  }
}

class _ErrorItem extends StatelessWidget {
  const _ErrorItem({required this.error});

  final PronunciationError error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${error.position + 1}',
              style: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.body.copyWith(fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${error.word} ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '→ '),
                      TextSpan(
                        text: '/${error.expected}/',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.h6,
                Text(
                  'Bạn đọc: /${error.actual}/',
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.suggestion,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 22),
          AppGap.w12,
          Expanded(
            child: Text(
              comment,
              style: AppTypography.body.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
