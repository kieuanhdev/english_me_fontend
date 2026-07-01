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
        appBar: const CommonAppBar(title: 'Chi tiết bài học', isTranslate: false),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _LessonHeader(title: lesson.title),
              AppGap.h16,
              if (lesson.explanationVi.trim().isNotEmpty)
                _Section(
                  icon: Icons.menu_book_rounded,
                  title: 'Giải thích',
                  content: lesson.explanationVi,
                ),
              if (lesson.whenToUseVi.trim().isNotEmpty)
                _Section(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Khi nào dùng',
                  content: lesson.whenToUseVi,
                ),
              if (lesson.tipsVi.trim().isNotEmpty)
                _Section(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Mẹo ghi nhớ',
                  content: lesson.tipsVi,
                  accent: AppColors.success,
                ),
              if (lesson.formulas.isNotEmpty) ...[
                const _Header(icon: Icons.functions_rounded, text: 'Công thức'),
                ...lesson.formulas.map((f) => _FormulaCard(formula: f)),
                AppGap.h16,
              ],
              if (lesson.keyWords.isNotEmpty) ...[
                const _Header(icon: Icons.label_outline_rounded, text: 'Từ khóa'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lesson.keyWords.map((k) => _KeywordChip(k)).toList(),
                ),
                AppGap.h16,
              ],
              if (lesson.examples.isNotEmpty) ...[
                const _Header(icon: Icons.chat_bubble_outline_rounded, text: 'Ví dụ'),
                ...lesson.examples.map((e) => _ExampleCard(example: e)),
                AppGap.h16,
              ],
              if (lesson.commonMistakes.isNotEmpty) ...[
                const _Header(
                  icon: Icons.error_outline_rounded,
                  text: 'Lỗi thường gặp',
                ),
                ...lesson.commonMistakes.map((m) => _MistakeCard(mistake: m)),
                AppGap.h16,
              ],
              if (showExercises && lesson.exercises.isNotEmpty) ...[
                const _Header(
                  icon: Icons.fitness_center_rounded,
                  text: 'Bài tập',
                ),
                ...lesson.exercises.map(
                  (e) => _ExerciseRenderer(
                    exercise: e,
                    lessonId: lessonId,
                    enablePractice: true,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─── Theory presentation widgets ─────────────────────────────────────────────

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 20,
                color: AppColors.onPrimaryFixed,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          AppGap.w8,
          Text(
            text,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.content,
    required this.icon,
    this.accent,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = accent ?? AppColors.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(left: BorderSide(color: c, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c, size: 18),
              AppGap.w8,
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: c,
                ),
              ),
            ],
          ),
          AppGap.h8,
          Text(
            content,
            style: AppTypography.bodyLarge.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({required this.formula});
  final GrammarFormula formula;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (formula.label.trim().isNotEmpty)
            Text(
              formula.label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          if (formula.label.trim().isNotEmpty) const SizedBox(height: 4),
          Text(
            formula.structure,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTypography.bodyLarge.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.example});
  final GrammarExample example;

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
            example.en,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          if (example.vi.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              example.vi,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          if (example.note.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              example.note,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.mistake});
  final GrammarMistake mistake;

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
          _MistakeLine(
            icon: Icons.close_rounded,
            color: AppColors.danger,
            label: 'Sai',
            text: mistake.wrong,
          ),
          const SizedBox(height: 6),
          _MistakeLine(
            icon: Icons.check_rounded,
            color: AppColors.success,
            label: 'Đúng',
            text: mistake.correct,
          ),
          if (mistake.explainVi.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              mistake.explainVi,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MistakeLine extends StatelessWidget {
  const _MistakeLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Exercise rendering ───────────────────────────────────────────────────────

class _ExerciseRenderer extends StatelessWidget {
  const _ExerciseRenderer({
    required this.exercise,
    required this.lessonId,
    this.enablePractice = false,
  });

  final GrammarExercise exercise;
  final String lessonId;

  /// When true, a wrong answer reveals a "Luyện thêm dạng này" AI button.
  final bool enablePractice;

  @override
  Widget build(BuildContext context) {
    return _ExerciseByType(
      order: exercise.exerciseOrder,
      type: (exercise.content['type'] ?? exercise.exerciseType).toString(),
      content: exercise.content,
      lessonId: lessonId,
      enablePractice: enablePractice,
    );
  }
}

/// Dispatches by exercise type. Shared so AI-generated practice items reuse the
/// same cards (with practice disabled to avoid endless chains).
class _ExerciseByType extends StatelessWidget {
  const _ExerciseByType({
    required this.order,
    required this.type,
    required this.content,
    required this.lessonId,
    required this.enablePractice,
  });

  final int order;
  final String type;
  final Map<String, dynamic> content;
  final String lessonId;
  final bool enablePractice;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'multiple_choice':
        return _MultipleChoiceExerciseCard(
          order: order,
          content: content,
          lessonId: lessonId,
          enablePractice: enablePractice,
        );
      case 'fill_blank':
        return _FillBlankExerciseCard(
          order: order,
          content: content,
          lessonId: lessonId,
          enablePractice: enablePractice,
        );
      case 'error_correction':
        return _ErrorCorrectionExerciseCard(
          order: order,
          content: content,
          lessonId: lessonId,
          enablePractice: enablePractice,
        );
      default:
        return _ExerciseCardShell(
          order: order,
          typeLabel: type,
          child: Text(
            (content['question'] ?? '').toString(),
            style: AppTypography.bodyLarge,
          ),
        );
    }
  }
}

/// Card chrome shared by all exercise types: border, padding, header badge.
class _ExerciseCardShell extends StatelessWidget {
  const _ExerciseCardShell({
    required this.order,
    required this.typeLabel,
    required this.child,
    this.icon,
  });

  final int order;
  final String typeLabel;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon ?? Icons.quiz_outlined, size: 16, color: AppColors.primary),
              AppGap.w8,
              Text(
                'Bài $order • $typeLabel',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppGap.h10,
          child,
        ],
      ),
    );
  }
}

/// Verdict banner + "làm lại" / "luyện thêm dạng này" actions, shared by all cards.
class _ExerciseFeedback extends StatelessWidget {
  const _ExerciseFeedback({
    required this.isCorrect,
    required this.title,
    required this.onReset,
    required this.lessonId,
    required this.exerciseType,
    required this.wrongContent,
    required this.enablePractice,
    this.detailLines = const [],
  });

  final bool isCorrect;
  final String title;
  final VoidCallback onReset;
  final String lessonId;
  final String exerciseType;
  final Map<String, dynamic> wrongContent;
  final bool enablePractice;
  final List<String> detailLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 220),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.successSoft : AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: (isCorrect ? AppColors.success : AppColors.danger)
                    .withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: isCorrect ? AppColors.successDark : AppColors.dangerDark,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isCorrect
                              ? AppColors.successDark
                              : AppColors.dangerDark,
                        ),
                      ),
                    ),
                  ],
                ),
                for (final line in detailLines)
                  if (line.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      line,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
        AppGap.h10,
        if (enablePractice && !isCorrect)
          _PracticeMoreSection(
            lessonId: lessonId,
            exerciseType: exerciseType,
            wrongContent: wrongContent,
          ),
        AppButton(
          label: 'Làm lại',
          onPressed: onReset,
          variant: AppButtonVariant.secondary,
          isTranslate: false,
          height: 50,
        ),
      ],
    );
  }
}

/// On demand, fetches AI practice items of the same type/mistake and renders
/// them inline. Generated items have practice disabled (no recursive chains).
class _PracticeMoreSection extends StatefulWidget {
  const _PracticeMoreSection({
    required this.lessonId,
    required this.exerciseType,
    required this.wrongContent,
  });

  final String lessonId;
  final String exerciseType;
  final Map<String, dynamic> wrongContent;

  @override
  State<_PracticeMoreSection> createState() => _PracticeMoreSectionState();
}

class _PracticeMoreSectionState extends State<_PracticeMoreSection> {
  bool _loading = false;
  String? _error;
  List<GrammarPracticeItem> _items = const [];

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = Get.find<GrammarRepository>();
      final items = await repo.generateSimilar(
        lessonId: widget.lessonId,
        exerciseType: widget.exerciseType,
        wrongContent: widget.wrongContent,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = items.isEmpty
            ? 'Chưa tạo được câu luyện. Vui lòng thử lại.'
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không tạo được câu luyện. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          label: 'Luyện thêm dạng này',
          onPressed: _loading ? null : _generate,
          isLoading: _loading,
          isTranslate: false,
          gradient: true,
          height: 50,
          leading: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        if (_error != null) ...[
          AppGap.h8,
          Text(
            _error!,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.danger,
              fontSize: 13,
            ),
          ),
        ],
        if (_items.isNotEmpty) ...[
          AppGap.h12,
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 16, color: AppColors.primary),
              AppGap.w8,
              Text(
                'Câu luyện AI tạo',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppGap.h10,
          ..._items.map(
            (it) => _ExerciseByType(
              order: 0,
              type: it.exerciseType,
              content: it.content,
              lessonId: widget.lessonId,
              enablePractice: false,
            ),
          ),
        ],
        AppGap.h10,
      ],
    );
  }
}

// ─── Multiple Choice ──────────────────────────────────────────────────────────

class _MultipleChoiceExerciseCard extends StatefulWidget {
  const _MultipleChoiceExerciseCard({
    required this.order,
    required this.content,
    required this.lessonId,
    required this.enablePractice,
  });

  final int order;
  final Map<String, dynamic> content;
  final String lessonId;
  final bool enablePractice;

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
    if (_submitted || (_selected ?? '').isEmpty) return;
    setState(() => _submitted = true);
  }

  void _reset() => setState(() {
    _selected = null;
    _submitted = false;
  });

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
    return _ExerciseCardShell(
      order: widget.order,
      typeLabel: 'Trắc nghiệm',
      icon: Icons.checklist_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              height: 50,
            )
          else
            _ExerciseFeedback(
              isCorrect: _isCorrect,
              title: _isCorrect ? 'Đúng rồi!' : 'Chưa đúng',
              onReset: _reset,
              lessonId: widget.lessonId,
              exerciseType: 'multiple_choice',
              wrongContent: widget.content,
              enablePractice: widget.enablePractice,
              detailLines: [_explainVi],
            ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
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
  const _FillBlankExerciseCard({
    required this.order,
    required this.content,
    required this.lessonId,
    required this.enablePractice,
  });

  final int order;
  final Map<String, dynamic> content;
  final String lessonId;
  final bool enablePractice;

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
    return _ExerciseCardShell(
      order: widget.order,
      typeLabel: 'Điền từ',
      icon: Icons.edit_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (_hints.isNotEmpty && !_submitted) ...[
            AppGap.h8,
            Wrap(
              spacing: 6,
              children: _hints
                  .map(
                    (h) => GestureDetector(
                      onTap: () => setState(() => _controller.text = h),
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
              height: 50,
            )
          else
            _ExerciseFeedback(
              isCorrect: _isCorrect,
              title: _isCorrect
                  ? 'Đúng rồi!'
                  : 'Chưa đúng — Đáp án: $_answer',
              onReset: _reset,
              lessonId: widget.lessonId,
              exerciseType: 'fill_blank',
              wrongContent: widget.content,
              enablePractice: widget.enablePractice,
              detailLines: [_explainVi],
            ),
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
    required this.lessonId,
    required this.enablePractice,
  });

  final int order;
  final Map<String, dynamic> content;
  final String lessonId;
  final bool enablePractice;

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

  void _reset() => setState(() {
    _selected = null;
    _submitted = false;
  });

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

  @override
  Widget build(BuildContext context) {
    return _ExerciseCardShell(
      order: widget.order,
      typeLabel: 'Tìm lỗi sai',
      icon: Icons.error_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
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
              height: 50,
            )
          else
            _ExerciseFeedback(
              isCorrect: _isCorrect,
              title: _isCorrect ? 'Đúng rồi!' : 'Chưa đúng',
              onReset: _reset,
              lessonId: widget.lessonId,
              exerciseType: 'error_correction',
              wrongContent: widget.content,
              enablePractice: widget.enablePractice,
              detailLines: [
                if (_correction.trim().isNotEmpty) 'Sửa lại: $_correction',
                _explainVi,
              ],
            ),
        ],
      ),
    );
  }
}
