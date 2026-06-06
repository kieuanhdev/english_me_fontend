import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/grammar/models/grammar_models.dart';
import 'package:englishme/modules/grammar/repositories/grammar_repository.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GrammarLessonDetailScreen extends StatelessWidget {
  const GrammarLessonDetailScreen({
    super.key,
    required this.lessonId,
    this.showExercises = true,
  });

  final String lessonId;

  /// When false, the lesson renders as a pure theory reference (exercises hidden).
  final bool showExercises;
  static final Map<String, Future<GrammarLessonDetail>> _futureCache = {};

  @override
  Widget build(BuildContext context) {
    if (lessonId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: const CommonAppBar(
          title: 'Chi tiết bài học',
          isTranslate: false,
        ),
        body: Center(
          child: Text(
            'Thiếu lessonId hợp lệ.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final repo = Get.find<GrammarRepository>();
    final future = _futureCache.putIfAbsent(
      lessonId,
      () => repo.getLessonDetail(lessonId),
    );
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CommonAppBar(title: 'Chi tiết bài học', isTranslate: false),
      body: FutureBuilder<GrammarLessonDetail>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không tải được bài học. Vui lòng thử lại.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          final lesson = snapshot.data;
          if (lesson == null) {
            return const Center(child: Text('Không có dữ liệu bài học.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Text(
                lesson.title,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              AppGap.h8,
              _Section(title: 'Giải thích', content: lesson.explanationVi),
              _Section(title: 'Khi nào dùng', content: lesson.whenToUseVi),
              _Section(title: 'Mẹo ghi nhớ', content: lesson.tipsVi),
              if (lesson.formulas.isNotEmpty) ...[
                const _Header(text: 'Công thức'),
                ...lesson.formulas.map(
                  (f) => _BulletLine(text: '${f.label}: ${f.structure}'),
                ),
                AppGap.h12,
              ],
              if (lesson.keyWords.isNotEmpty) ...[
                const _Header(text: 'Từ khóa'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lesson.keyWords
                      .map(
                        (k) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            k,
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                AppGap.h12,
              ],
              if (lesson.examples.isNotEmpty) ...[
                const _Header(text: 'Ví dụ'),
                ...lesson.examples.map(
                  (e) => _CardLine(title: e.en, subtitle: '${e.vi}\n${e.note}'),
                ),
                AppGap.h12,
              ],
              if (lesson.commonMistakes.isNotEmpty) ...[
                const _Header(text: 'Lỗi thường gặp'),
                ...lesson.commonMistakes.map(
                  (m) => _CardLine(
                    title: 'Sai: ${m.wrong}',
                    subtitle: 'Đúng: ${m.correct}\n${m.explainVi}',
                  ),
                ),
                AppGap.h12,
              ],
              if (showExercises && lesson.exercises.isNotEmpty) ...[
                const _Header(text: 'Bài tập'),
                ...lesson.exercises.map((e) => _ExerciseRenderer(exercise: e)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(text: title),
          Text(content, style: AppTypography.bodyLarge),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text, style: AppTypography.bodyLarge)),
        ],
      ),
    );
  }
}

class _CardLine extends StatelessWidget {
  const _CardLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRenderer extends StatelessWidget {
  const _ExerciseRenderer({required this.exercise});

  final GrammarExercise exercise;

  @override
  Widget build(BuildContext context) {
    final type = (exercise.content['type'] ?? exercise.exerciseType).toString();
    if (type == 'multiple_choice') {
      return _MultipleChoiceExerciseCard(
        order: exercise.exerciseOrder,
        content: exercise.content,
      );
    }
    if (type == 'fill_blank') {
      return _FillBlankExerciseCard(
        order: exercise.exerciseOrder,
        content: exercise.content,
      );
    }
    if (type == 'error_correction') {
      return _ErrorCorrectionExerciseCard(
        order: exercise.exerciseOrder,
        content: exercise.content,
      );
    }

    return _CardLine(
      title: 'Bài ${exercise.exerciseOrder} • $type',
      subtitle: (exercise.content['question'] ?? '').toString(),
    );
  }
}

class _MultipleChoiceExerciseCard extends StatefulWidget {
  const _MultipleChoiceExerciseCard({
    required this.order,
    required this.content,
  });

  final int order;
  final Map<String, dynamic> content;

  @override
  State<_MultipleChoiceExerciseCard> createState() =>
      _MultipleChoiceExerciseCardState();
}

class _MultipleChoiceExerciseCardState
    extends State<_MultipleChoiceExerciseCard> {
  String? _selected;
  bool _submitted = false;

  String get _question => (widget.content['question'] ?? '').toString();
  String get _answer => (widget.content['answer'] ?? '').toString();
  String get _explainVi => (widget.content['explain_vi'] ?? '').toString();

  List<String> get _options {
    final raw = widget.content['options'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  bool get _isCorrect => _submitted && (_selected ?? '') == _answer;

  void _select(String value) {
    if (_submitted) return;
    setState(() => _selected = value);
  }

  void _submit() {
    if (_submitted) return;
    if ((_selected ?? '').isEmpty) return;
    setState(() => _submitted = true);
  }

  void _reset() {
    setState(() {
      _selected = null;
      _submitted = false;
    });
  }

  Color _optionBorderColor(String opt) {
    if (!_submitted) {
      return opt == _selected ? AppColors.primary : AppColors.outlineVariant;
    }
    if (opt == _answer) return AppColors.success;
    if (opt == _selected && opt != _answer) return AppColors.danger;
    return AppColors.outlineVariant;
  }

  Color _optionBgColor(String opt) {
    if (!_submitted) {
      return opt == _selected
          ? AppColors.primarySoft
          : AppColors.surfaceContainerLowest;
    }
    if (opt == _answer) return AppColors.successSoft;
    if (opt == _selected && opt != _answer) return AppColors.dangerSoft;
    return AppColors.surfaceContainerLowest;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bài ${widget.order} • Trắc nghiệm',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          AppGap.h8,
          Text(
            _question,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          AppGap.h12,
          ..._options.map(
            (opt) => _OptionTile(
              text: opt,
              selected: opt == _selected,
              disabled: _submitted,
              borderColor: _optionBorderColor(opt),
              backgroundColor: _optionBgColor(opt),
              trailing: _submitted && opt == _answer
                  ? Icons.check_circle_rounded
                  : (_submitted && opt == _selected && opt != _answer)
                  ? Icons.cancel_rounded
                  : null,
              trailingColor: _submitted && opt == _answer
                  ? AppColors.success
                  : AppColors.danger,
              onTap: () => _select(opt),
            ),
          ),
          AppGap.h12,
          if (!_submitted)
            AppButton(
              label: 'Nộp đáp án',
              onPressed: (_selected ?? '').isEmpty ? null : _submit,
              isTranslate: false,
              height: 52,
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? AppColors.successSoft
                    : AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: (_isCorrect ? AppColors.success : AppColors.danger)
                      .withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCorrect ? 'Đúng rồi!' : 'Chưa đúng',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _isCorrect
                          ? AppColors.successDark
                          : AppColors.dangerDark,
                    ),
                  ),
                  if (_explainVi.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _explainVi,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h10,
            AppButton(
              label: 'Làm lại',
              onPressed: _reset,
              variant: AppButtonVariant.secondary,
              isTranslate: false,
              height: 52,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.disabled,
    required this.borderColor,
    required this.backgroundColor,
    required this.onTap,
    this.trailing,
    required this.trailingColor,
  });

  final String text;
  final bool selected;
  final bool disabled;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final IconData? trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: disabled ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: disabled
                        ? AppColors.textSecondary
                        : AppColors.onSurface,
                  ),
                ),
              ),
              if (trailing != null)
                Icon(trailing, color: trailingColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Fill in the Blank ───────────────────────────────────────────────────────

class _FillBlankExerciseCard extends StatefulWidget {
  const _FillBlankExerciseCard({required this.order, required this.content});

  final int order;
  final Map<String, dynamic> content;

  @override
  State<_FillBlankExerciseCard> createState() => _FillBlankExerciseCardState();
}

class _FillBlankExerciseCardState extends State<_FillBlankExerciseCard> {
  final _controller = TextEditingController();
  bool _submitted = false;

  String get _sentence => (widget.content['sentence'] ?? '').toString();
  String get _answer =>
      (widget.content['answer'] ?? '').toString().trim().toLowerCase();
  String get _explainVi => (widget.content['explain_vi'] ?? '').toString();
  List<String> get _hints {
    final raw = widget.content['hints'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  bool get _isCorrect =>
      _submitted && _controller.text.trim().toLowerCase() == _answer;

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _submitted = true);
  }

  void _reset() {
    _controller.clear();
    setState(() => _submitted = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parts = _sentence.split('___');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bài ${widget.order} • Điền từ',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          AppGap.h8,
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              if (parts.isNotEmpty)
                Text(
                  parts[0].trimRight(),
                  style: AppTypography.bodyLarge.copyWith(fontSize: 15),
                ),
              Container(
                constraints: const BoxConstraints(minWidth: 80, maxWidth: 160),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _submitted
                          ? (_isCorrect ? AppColors.success : AppColors.danger)
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                child: _submitted
                    ? Text(
                        _controller.text.trim(),
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _isCorrect
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      )
                    : TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
              ),
              if (parts.length > 1)
                Text(
                  parts[1].trimLeft(),
                  style: AppTypography.bodyLarge.copyWith(fontSize: 15),
                ),
            ],
          ),
          if (_hints.isNotEmpty) ...[
            AppGap.h8,
            Wrap(
              spacing: 6,
              children: _hints
                  .map(
                    (h) => GestureDetector(
                      onTap: _submitted
                          ? null
                          : () => setState(() => _controller.text = h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          h,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          AppGap.h12,
          if (!_submitted)
            AppButton(
              label: 'Nộp đáp án',
              onPressed: _submit,
              isTranslate: false,
              height: 52,
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? AppColors.successSoft
                    : AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: (_isCorrect ? AppColors.success : AppColors.danger)
                      .withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCorrect ? 'Đúng rồi!' : 'Chưa đúng — Đáp án: $_answer',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _isCorrect
                          ? AppColors.successDark
                          : AppColors.dangerDark,
                    ),
                  ),
                  if (_explainVi.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _explainVi,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h10,
            AppButton(
              label: 'Làm lại',
              onPressed: _reset,
              variant: AppButtonVariant.secondary,
              isTranslate: false,
              height: 52,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Error Correction ────────────────────────────────────────────────────────

class _ErrorCorrectionExerciseCard extends StatefulWidget {
  const _ErrorCorrectionExerciseCard({
    required this.order,
    required this.content,
  });

  final int order;
  final Map<String, dynamic> content;

  @override
  State<_ErrorCorrectionExerciseCard> createState() =>
      _ErrorCorrectionExerciseCardState();
}

class _ErrorCorrectionExerciseCardState
    extends State<_ErrorCorrectionExerciseCard> {
  String? _selected;
  bool _submitted = false;

  String get _instruction =>
      (widget.content['instruction'] ?? 'Tìm phần sai trong câu dưới đây:')
          .toString();
  String get _answer => (widget.content['answer'] ?? '').toString();
  String get _correction => (widget.content['correction'] ?? '').toString();
  String get _explainVi => (widget.content['explain_vi'] ?? '').toString();

  List<String> get _segments {
    final raw = widget.content['segments'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  bool get _isCorrect => _submitted && _selected == _answer;

  Color _segmentBorder(String seg) {
    if (!_submitted) {
      return seg == _selected ? AppColors.primary : AppColors.outlineVariant;
    }
    if (seg == _answer) return AppColors.success;
    if (seg == _selected && seg != _answer) return AppColors.danger;
    return AppColors.outlineVariant;
  }

  Color _segmentBg(String seg) {
    if (!_submitted) {
      return seg == _selected
          ? AppColors.primarySoft
          : AppColors.surfaceContainerLowest;
    }
    if (seg == _answer) return AppColors.successSoft;
    if (seg == _selected && seg != _answer) return AppColors.dangerSoft;
    return AppColors.surfaceContainerLowest;
  }

  void _reset() => setState(() {
    _selected = null;
    _submitted = false;
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bài ${widget.order} • Tìm lỗi sai',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          AppGap.h8,
          Text(
            _instruction,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          AppGap.h12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _segments
                .map(
                  (seg) => GestureDetector(
                    onTap: _submitted
                        ? null
                        : () => setState(() => _selected = seg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _segmentBg(seg),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: _segmentBorder(seg),
                          width: _selected == seg ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        seg,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 14,
                          fontWeight: _selected == seg
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          AppGap.h12,
          if (!_submitted)
            AppButton(
              label: 'Nộp đáp án',
              onPressed: (_selected ?? '').isEmpty
                  ? null
                  : () => setState(() => _submitted = true),
              isTranslate: false,
              height: 52,
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? AppColors.successSoft
                    : AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: (_isCorrect ? AppColors.success : AppColors.danger)
                      .withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCorrect ? 'Đúng rồi!' : 'Chưa đúng',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _isCorrect
                          ? AppColors.successDark
                          : AppColors.dangerDark,
                    ),
                  ),
                  if (_correction.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Sửa lại: $_correction',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (_explainVi.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _explainVi,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h10,
            AppButton(
              label: 'Làm lại',
              onPressed: _reset,
              variant: AppButtonVariant.secondary,
              isTranslate: false,
              height: 52,
            ),
          ],
        ],
      ),
    );
  }
}
