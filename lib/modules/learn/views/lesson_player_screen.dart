import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/learn/controllers/lesson_player_controller.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/theme/app_theme.dart';

class LessonPlayerScreen extends GetView<LessonPlayerController> {
  const LessonPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              AppGap.h8,
              AppMainAppBar(
                title: controller.detail.value?.title ?? 'Bài học',
                showBack: true,
                showSettings: false,
                showNotification: false,
                onBack: Get.back,
              ),
              AppGap.h16,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Stepper(
                  phase: controller.phase.value,
                  reviewMode: controller.reviewMode.value,
                  onTapStep: controller.goToPhase,
                ),
              ),
              AppGap.h12,
              Expanded(child: _phaseBody(controller.phase.value)),
            ],
          );
        }),
      ),
    );
  }

  Widget _phaseBody(LessonPhase phase) {
    switch (phase) {
      case LessonPhase.theory:
        return _TheoryView(c: controller);
      case LessonPhase.practice:
        return _PracticeView(c: controller);
      case LessonPhase.quiz:
        return _QuizView(c: controller);
      case LessonPhase.summary:
        return _SummaryView(c: controller);
      case LessonPhase.extraPractice:
        return _ExtraPracticeView(c: controller);
    }
  }
}

// ── Thanh tiến trình 4 bước ──
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.phase,
    required this.onTapStep,
    this.reviewMode = false,
  });
  final LessonPhase phase;
  final bool reviewMode;
  final ValueChanged<LessonPhase> onTapStep;

  @override
  Widget build(BuildContext context) {
    final int idx = switch (phase) {
      LessonPhase.theory => 0,
      LessonPhase.practice => 1,
      LessonPhase.quiz => 2,
      LessonPhase.summary => 3,
      LessonPhase.extraPractice => 3, // luyện thêm: coi như đã ở bước cuối
    };
    const phases = [
      LessonPhase.theory,
      LessonPhase.practice,
      LessonPhase.quiz,
      LessonPhase.summary,
    ];
    Widget dot(String label, int i) {
      final active = i <= idx;
      // Ôn tập (bài đã hoàn thành): bấm tự do mọi bước (trừ bước đang xem).
      // Làm bài: chỉ cho lùi về bước ĐÃ QUA, và khoá hẳn khi đã sang "Kết quả".
      final canTap = reviewMode
          ? i != idx
          : (i < idx && phase != LessonPhase.summary);
      return GestureDetector(
        onTap: canTap ? () => onTapStep(phases[i]) : null,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    active ? AppColors.primary : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: canTap
                    ? Border.all(color: AppColors.onPrimaryFixed, width: 1.5)
                    : null,
              ),
              // Ôn tập: luôn hiện số (đi tự do, không gợi ý hướng). Làm bài: chấm
              // bấm-được là mũi tên lùi để báo "quay lại bước đã qua".
              child: (canTap && !reviewMode)
                  ? Icon(
                      Icons.arrow_back_rounded,
                      size: 14,
                      color: AppColors.onPrimaryFixed,
                    )
                  : Text(
                      '${i + 1}',
                      style: AppTypography.labelSmall.copyWith(
                        color: active
                            ? AppColors.onPrimaryFixed
                            : AppColors.iconMuted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            AppGap.h4,
            Text(
              label,
              style: AppTypography.labelXSmall.copyWith(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    // Đường kẻ nối giữa 2 bước; tô primary khi bước bên phải (stepRight) đã active.
    Widget connector(int stepRight) {
      final reached = stepRight <= idx;
      return Expanded(
        child: Padding(
          // Căn ngang tâm chấm (chấm cao 26 → tâm ~13px), chừa chỗ cho label phía dưới.
          padding: const EdgeInsets.only(top: 13, left: 4, right: 4),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: reached ? AppColors.primary : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dot('Lý thuyết', 0),
        connector(1),
        dot('Luyện tập', 1),
        connector(2),
        dot('Kiểm tra', 2),
        connector(3),
        dot('Kết quả', 3),
      ],
    );
  }
}

// ── Nút CTA chính (full width), dùng AppButton chuẩn toàn app ──
class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AppButton(
          label: label,
          onPressed: onPressed,
          isTranslate: false,
        ),
      ),
    );
  }
}

// ── Khung tiêu đề một mục trong lý thuyết ──
Widget _sectionCard(String title, Widget child) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          AppGap.h10,
          child,
        ],
      ),
    );

// ══════════ GIAI ĐOẠN 1: LÝ THUYẾT ══════════
class _TheoryView extends StatelessWidget {
  const _TheoryView({required this.c});
  final LessonPlayerController c;

  @override
  Widget build(BuildContext context) {
    final t = c.detail.value!.theory;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          children: [
            _sectionCard('🔥 KHỞI ĐỘNG',
                Text(t.warmup, style: AppTypography.bodyRegular)),
            _sectionCard(
              '🎯 MỤC TIÊU',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: t.objectives.map((o) => _bullet(o)).toList(),
              ),
            ),
            if ((t.grammarHtml ?? '').trim().isNotEmpty)
              _sectionCard(
                '📖 NGỮ PHÁP',
                Text(
                  t.grammarHtml!.trim(),
                  style: AppTypography.bodyRegular.copyWith(height: 1.5),
                ),
              ),
            if (t.vocabBlock.isNotEmpty)
              _sectionCard(
                '📚 TỪ VỰNG',
                Column(
                  children: t.vocabBlock
                      .map((v) => _VocabRow(item: v))
                      .toList(growable: false),
                ),
              ),
            if (t.examples.isNotEmpty)
              _sectionCard(
                '📝 VÍ DỤ',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: t.examples
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.en,
                                    style: AppTypography.bodyRegular.copyWith(
                                      fontWeight: FontWeight.w700,
                                    )),
                                Text(e.vi, style: AppTypography.bodySmall),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            if (t.commonMistakes.isNotEmpty)
              _sectionCard(
                '⚠️ LỖI THƯỜNG GẶP',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: t.commonMistakes.map((m) => _bullet(m)).toList(),
                ),
              ),
            if (t.tips.isNotEmpty)
              _sectionCard(
                '💡 MẸO',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: t.tips.map((m) => _bullet(m)).toList(),
                ),
              ),
          ],
        ),
      ),
      _PrimaryCta(
        label: c.reviewMode.value
            ? 'Xem luyện tập →'
            : 'Tôi đã hiểu → Vào luyện tập',
        onPressed: c.completeTheory,
      ),
    ]);
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ', style: AppTypography.bodyRegular),
            Expanded(child: Text(text, style: AppTypography.bodyRegular)),
          ],
        ),
      );
}

class _VocabRow extends StatelessWidget {
  const _VocabRow({required this.item});
  final VocabItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.word,
                        style: AppTypography.bodyRegular
                            .copyWith(fontWeight: FontWeight.w800)),
                    AppGap.w8,
                    Text(item.ipa, style: AppTypography.ipa.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                AppGap.h2,
                Text(item.meaningVi, style: AppTypography.bodySmall),
                if (item.example.isNotEmpty)
                  Text('"${item.example}"',
                      style: AppTypography.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      )),
              ],
            ),
          ),
          _VocabSpeakButton(text: item.word),
        ],
      ),
    );
  }
}

// ══════════ GIAI ĐOẠN 2: LUYỆN TẬP ══════════
class _PracticeView extends StatelessWidget {
  const _PracticeView({required this.c});
  final LessonPlayerController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final a = c.currentPractice;
      if (a == null) return const SizedBox.shrink();
      final total = c.detail.value!.exercises.length;
      final answered = c.practiceAnswered.value;
      final correct = c.practiceIsCorrect;
      return Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            children: [
              _QuestionProgress(current: c.practiceIndex.value + 1, total: total),
              AppGap.h16,
              _QuestionCard(
                type: a.type,
                difficulty: a.difficulty,
                question: a.question,
                child: _PracticeBody(c: c, a: a, answered: answered),
              ),
              if (answered) ...[
                AppGap.h12,
                _FeedbackCard(correct: correct, explanation: a.explanationVi),
              ],
              if (c.retryQueue.isNotEmpty) ...[
                AppGap.h12,
                Row(children: [
                  Icon(Icons.replay_rounded,
                      size: 16, color: AppColors.tertiary),
                  AppGap.w6,
                  Text('Hàng đợi làm lại: ${c.retryQueue.length} câu',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.tertiary)),
                ]),
              ],
            ],
          ),
        ),
        _PrimaryCta(
          label: !answered ? 'Kiểm tra' : 'Câu tiếp theo →',
          onPressed: !answered
              ? (c.canCheckPractice ? c.checkPractice : null)
              : () => c.nextPractice(),
        ),
      ]);
    });
  }
}

/// Thân câu hỏi practice — render khác nhau theo dạng bài.
class _PracticeBody extends StatelessWidget {
  const _PracticeBody({required this.c, required this.a, required this.answered});
  final LessonPlayerController c;
  final CurriculumActivity a;
  final bool answered;

  @override
  Widget build(BuildContext context) {
    // fill_blank | translation | error_correction → ô nhập text
    if (a.isTextInput) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.sourceText.isNotEmpty) ...[
            _SourceTextCard(text: a.sourceText, isError: a.isErrorCorrection),
            AppGap.h12,
          ],
          _FillBlankField(
            key: ValueKey('practice-${a.id}'),
            enabled: !answered,
            hint: a.isFillBlank ? 'Nhập đáp án' : 'Nhập câu trả lời',
            onChanged: c.typePractice,
          ),
        ],
      );
    }
    if (a.isMatch) {
      return _MatchBody(
        pairs: a.pairs,
        selected: c.practiceMatch,
        enabled: !answered,
        onPick: c.matchPractice,
      );
    }
    if (a.isOrdering) {
      return _OrderingBody(
        tokens: a.tokens,
        order: c.practiceOrder,
        enabled: !answered,
        onToggle: c.toggleOrderPractice,
        onReset: c.resetOrderPractice,
      );
    }
    if (a.isListening) {
      return _ListeningBody(
        activity: a,
        selected: c.practiceSelected.value,
        answered: answered,
        onSelect: c.selectPractice,
      );
    }
    if (a.isPronunciation) {
      return _PronunciationBody(
        activity: a,
        pronounced: c.practicePronounced.value,
        enabled: !answered,
        onPronounced: c.markPronouncedPractice,
      );
    }
    final selected = c.practiceSelected.value;
    return Column(
      children: a.options.map((o) {
        _OptionVisual visual;
        if (answered) {
          if (o.id == a.correctOptionId) {
            visual = _OptionVisual.correct;
          } else if (o.id == selected) {
            visual = _OptionVisual.wrong;
          } else {
            visual = _OptionVisual.idle;
          }
        } else {
          visual = o.id == selected ? _OptionVisual.selected : _OptionVisual.idle;
        }
        return _OptionTile(
          text: o.text,
          visual: visual,
          onTap: answered ? null : () => c.selectPractice(o.id),
        );
      }).toList(),
    );
  }
}

// ══════════ GIAI ĐOẠN 3: MINI-QUIZ ══════════
class _QuizView extends StatelessWidget {
  const _QuizView({required this.c});
  final LessonPlayerController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final a = c.currentQuiz;
      if (a == null) return const SizedBox.shrink();
      final detail = c.detail.value!;
      final total = detail.quiz.length;
      final selected = c.quizSelected.value;
      // KHÔNG hiện đúng/sai giữa chừng — chỉ thu nhận đáp án.
      final Widget quizBody;
      if (a.isTextInput) {
        quizBody = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.sourceText.isNotEmpty) ...[
              _SourceTextCard(text: a.sourceText, isError: a.isErrorCorrection),
              AppGap.h12,
            ],
            _FillBlankField(
              key: ValueKey('quiz-${a.id}'),
              enabled: true,
              hint: a.isFillBlank ? 'Nhập đáp án' : 'Nhập câu trả lời',
              onChanged: c.typeQuiz,
            ),
          ],
        );
      } else if (a.isOrdering) {
        quizBody = _OrderingBody(
          tokens: a.tokens,
          order: c.quizOrder,
          enabled: true,
          onToggle: c.toggleOrderQuiz,
          onReset: c.resetOrderQuiz,
        );
      } else if (a.isListening) {
        quizBody = _ListeningBody(
          activity: a,
          selected: selected,
          answered: false,
          onSelect: c.selectQuiz,
        );
      } else if (a.isMatch) {
        quizBody = _MatchBody(
          pairs: a.pairs,
          selected: c.quizMatch,
          enabled: true,
          onPick: c.matchQuiz,
        );
      } else if (a.isPronunciation) {
        quizBody = _PronunciationBody(
          activity: a,
          pronounced: c.quizPronounced.value,
          enabled: true,
          onPronounced: c.markPronouncedQuiz,
        );
      } else {
        quizBody = Column(
          children: a.options
              .map((o) => _OptionTile(
                    text: o.text,
                    visual: o.id == selected
                        ? _OptionVisual.selected
                        : _OptionVisual.idle,
                    onTap: () => c.selectQuiz(o.id),
                  ))
              .toList(),
        );
      }
      return Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            children: [
              _QuestionProgress(current: c.quizIndex.value + 1, total: total),
              AppGap.h16,
              _QuestionCard(
                type: a.type,
                difficulty: a.difficulty,
                question: a.question,
                quizMode: true,
                child: quizBody,
              ),
            ],
          ),
        ),
        _PrimaryCta(
          label: c.quizIndex.value < total - 1
              ? 'Câu tiếp →'
              : (c.reviewMode.value ? 'Xem lại kết quả' : 'Nộp bài'),
          // Ôn tập: cho qua câu tự do (không cần điền). Làm bài: phải trả lời mới đi tiếp.
          onPressed:
              (c.reviewMode.value || c.canSubmitQuiz) ? c.nextQuiz : null,
        ),
      ]);
    });
  }
}

// ══════════ KẾT QUẢ ══════════
class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.c});
  final LessonPlayerController c;

  @override
  Widget build(BuildContext context) {
    final r = c.result.value;
    // Ôn tập (bài đã hoàn thành từ trước, chưa nộp lại trong phiên này) → chưa có
    // kết quả mới để hiển thị; cho xem trạng thái "đã hoàn thành" thay vì crash.
    if (r == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded,
                size: 64, color: AppColors.success),
            AppGap.h16,
            Text('Bạn đã hoàn thành bài học này',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular
                    .copyWith(fontWeight: FontWeight.w800)),
            AppGap.h8,
            Text('Bấm các bước phía trên để xem lại lý thuyết và bài tập.',
                textAlign: TextAlign.center, style: AppTypography.bodySmall),
            AppGap.h32,
            AppButton(
              label: 'Về danh sách bài',
              onPressed: Get.back,
              variant: AppButtonVariant.secondary,
              isTranslate: false,
            ),
          ],
        ),
      );
    }
    final color = r.passed ? AppColors.success : AppColors.tertiary;
    final hasNext = (r.nextLessonId ?? '').isNotEmpty;
    final title = !r.passed
        ? 'Chưa đạt'
        : (r.score >= 90 ? 'Xuất sắc!' : 'Hoàn thành!');
    final subtitle = !r.passed
        ? 'Cần ≥70% để qua bài. Xem lại rồi thử lại nhé!'
        : (r.unitCompleted
            ? 'Bạn đã hoàn thành toàn bộ unit này 🎉'
            : 'Tiếp tục giữ phong độ nào!');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Vòng tròn điểm — viền dày theo trạng thái, điểm nổi bật ở giữa.
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${r.score}',
                    style: AppTypography.displayLarge
                        .copyWith(color: color, fontSize: 40, height: 1)),
                Text('ĐIỂM',
                    style: AppTypography.labelXSmall.copyWith(
                        color: color, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          AppGap.h20,
          Text(title,
              style: AppTypography.headlineMedium.copyWith(color: color)),
          AppGap.h6,
          Text(subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall),
          AppGap.h20,

          // Hàng chip thông tin: XP + ngưỡng đạt.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              if (r.passed && r.xpEarned > 0)
                _ResultChip(
                  icon: Icons.bolt_rounded,
                  label: '+${r.xpEarned} XP',
                  color: AppColors.tertiary,
                ),
              _ResultChip(
                icon: r.passed
                    ? Icons.check_circle_rounded
                    : Icons.flag_rounded,
                label: 'Ngưỡng đạt 70%',
                color: color,
              ),
            ],
          ),
          AppGap.h24,

          // Tiến độ unit sau bài học này.
          _UnitProgressBar(
            progress: r.unitProgress.clamp(0, 1).toDouble(),
            completed: r.unitCompleted,
          ),

          const Spacer(flex: 3),

          // Nút hành động đúng ngữ cảnh.
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Về danh sách',
                  onPressed: Get.back,
                  variant: AppButtonVariant.secondary,
                  height: 48,
                  textStyle: AppTypography.bodyRegular
                      .copyWith(fontWeight: FontWeight.w800),
                  isTranslate: false,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: AppButton(
                  // Đạt + còn bài → sang bài kế. Đạt nhưng hết bài (xong unit) →
                  // về danh sách Unit để chọn unit khác. Chưa đạt → làm lại.
                  label: !r.passed
                      ? 'Làm lại bài'
                      : (hasNext ? 'Bài tiếp theo →' : 'Chọn Unit khác →'),
                  onPressed: !r.passed
                      ? c.retryLesson
                      : (hasNext ? () => c.goToNextLesson() : c.goToUnitList),
                  height: 48,
                  textStyle: AppTypography.bodyRegular
                      .copyWith(fontWeight: FontWeight.w800),
                  isTranslate: false,
                ),
              ),
            ],
          ),
          AppGap.h12,
          // Luyện tập thêm với AI — sinh câu hỏi mới từ lý thuyết bài học.
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    c.isGeneratingExtra.value ? null : c.startExtraPractice,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: c.isGeneratingExtra.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                  c.isGeneratingExtra.value
                      ? 'Đang tạo câu hỏi...'
                      : 'Luyện tập thêm với AI',
                  style: AppTypography.bodyRegular
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip thông tin nhỏ ở màn Kết quả (XP, ngưỡng đạt…).
class _ResultChip extends StatelessWidget {
  const _ResultChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          AppGap.w6,
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

/// Thanh tiến độ unit ở màn Kết quả.
class _UnitProgressBar extends StatelessWidget {
  const _UnitProgressBar({required this.progress, required this.completed});
  final double progress;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiến độ unit',
                  style: AppTypography.labelSmall
                      .copyWith(fontWeight: FontWeight.w800)),
              Text(completed ? 'Hoàn thành 🎉' : '$pct%',
                  style: AppTypography.labelSmall.copyWith(
                    color: completed ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.w900,
                  )),
            ],
          ),
          AppGap.h8,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                completed ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Widget con dùng chung ───────────────

/// Card bao câu hỏi + thân bài tập — đồng nhất với phong cách card của app,
/// tránh cảm giác "trống" do nội dung trôi nổi trên nền.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.type,
    required this.difficulty,
    required this.question,
    required this.child,
    this.quizMode = false,
  });
  final String type;
  final String difficulty;
  final String question;
  final Widget child;
  final bool quizMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nhãn loại bài tập (pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              quizMode
                  ? _typeLabel(type)
                  : '${_typeLabel(type)} · ${_difficultyLabel(difficulty)}',
              style: AppTypography.labelXSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppGap.h12,
          Text(
            question,
            style: AppTypography.headlineMedium.copyWith(fontSize: 17),
          ),
          AppGap.h18,
          child,
        ],
      ),
    );
  }
}

/// Thanh tiến trình câu (x/total + pill bar) — đồng nhất với study session/test.
class _QuestionProgress extends StatelessWidget {
  const _QuestionProgress({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        AppGap.w10,
        Text(
          '$current/$total',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

enum _OptionVisual { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.visual,
    required this.onTap,
  });
  final String text;
  final _OptionVisual visual;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color fg) = switch (visual) {
      _OptionVisual.correct => (
          AppColors.successSoft,
          AppColors.success,
          AppColors.onSurface
        ),
      _OptionVisual.wrong => (
          AppColors.dangerSoft,
          AppColors.danger,
          AppColors.onSurface
        ),
      _OptionVisual.selected => (
          AppColors.primarySoft,
          AppColors.primary,
          AppColors.onSurface
        ),
      _OptionVisual.idle => (
          AppColors.surfaceContainerLowest,
          AppColors.outlineVariant,
          AppColors.onSurface
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(text,
                      style: AppTypography.bodyRegular.copyWith(color: fg)),
                ),
                if (visual == _OptionVisual.correct)
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
                if (visual == _OptionVisual.wrong)
                  Icon(Icons.cancel_rounded, color: AppColors.danger, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.correct, required this.explanation});
  final bool correct;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.tertiary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (correct ? AppColors.successSoft : AppColors.recommendationOrangeBg),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(correct ? Icons.check_circle_rounded : Icons.info_rounded,
              color: color, size: 20),
          AppGap.w8,
          Expanded(
            child: Text(
              '${correct ? "Chính xác! " : "Chưa đúng. "}$explanation',
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ô nhập đáp án cho grammar_fill_blank.
/// Stateful + controller riêng để không bị reset con trỏ khi Obx cha rebuild.
class _FillBlankField extends StatefulWidget {
  const _FillBlankField({
    super.key,
    required this.enabled,
    required this.onChanged,
    this.hint = 'Nhập đáp án',
  });
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String hint;
  @override
  State<_FillBlankField> createState() => _FillBlankFieldState();
}

class _FillBlankFieldState extends State<_FillBlankField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      autocorrect: false,
      minLines: 1,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      style: AppTypography.bodyRegular,
      decoration: InputDecoration(labelText: widget.hint),
      onChanged: widget.onChanged,
    );
  }
}

/// Thẻ hiển thị câu nguồn (translation: câu tiếng Anh; error_correction: câu sai cần sửa).
class _SourceTextCard extends StatelessWidget {
  const _SourceTextCard({required this.text, required this.isError});
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.recommendationOrangeBg
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isError ? AppColors.tertiary.withValues(alpha: 0.4) : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.translate_rounded,
            size: 18,
            color: isError ? AppColors.tertiary : AppColors.primary,
          ),
          AppGap.w8,
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.w700,
                decoration: isError ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── sentence_ordering: chọn token theo thứ tự để ghép thành câu ──
class _OrderingBody extends StatelessWidget {
  const _OrderingBody({
    required this.tokens,
    required this.order,
    required this.enabled,
    required this.onToggle,
    required this.onReset,
  });
  final List<String> tokens;
  final List<int> order; // các index đã chọn, theo thứ tự
  final bool enabled;
  final ValueChanged<int> onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Khu vực câu đang ghép
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: order.isEmpty
              ? Text('Chạm vào các từ bên dưới để xếp câu…',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: order
                      .map((i) => _Chip(
                            label: tokens[i],
                            selected: true,
                            onTap: enabled ? () => onToggle(i) : null,
                          ))
                      .toList(),
                ),
        ),
        AppGap.h12,
        // Kho token — LUÔN hiển thị đủ token để kích thước kho không đổi khi
        // chọn/bỏ. Token đã chọn chỉ làm mờ ("đã dùng"), bấm vào không làm gì
        // (muốn bỏ thì chạm chip ở khu ghép câu phía trên).
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < tokens.length; i++)
              _Chip(
                label: tokens[i],
                selected: false,
                used: order.contains(i),
                onTap: (enabled && !order.contains(i)) ? () => onToggle(i) : null,
              ),
          ],
        ),
        // Nút "Xếp lại" LUÔN chiếm chỗ (chỉ disable khi chưa chọn từ nào) để
        // tổng chiều cao không nhảy khi bắt đầu xếp.
        AppGap.h8,
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: 'Xếp lại',
            isTranslate: false,
            variant: AppButtonVariant.text,
            expand: false,
            leading: const Icon(Icons.refresh_rounded, size: 16),
            onPressed: (order.isNotEmpty && enabled) ? onReset : null,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.used = false,
  });
  final String label;
  final bool selected;
  final bool used; // đã chọn (ở kho): làm mờ, giữ nguyên kích thước
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Material(
      color: selected ? AppColors.primarySoft : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyRegular.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
    // Token đã dùng: mờ đi nhưng VẪN chiếm chỗ → kho không co lại, layout không nhảy.
    return Opacity(opacity: used ? 0.35 : 1, child: chip);
  }
}

// ── listening_choice: nghe (TTS) rồi chọn đáp án ──
class _ListeningBody extends StatelessWidget {
  const _ListeningBody({
    required this.activity,
    required this.selected,
    required this.answered,
    required this.onSelect,
  });
  final CurriculumActivity activity;
  final String? selected;
  final bool answered;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AudioButton(text: activity.audioText),
        AppGap.h16,
        ...activity.options.map((o) {
          _OptionVisual visual;
          if (answered) {
            if (o.id == activity.correctOptionId) {
              visual = _OptionVisual.correct;
            } else if (o.id == selected) {
              visual = _OptionVisual.wrong;
            } else {
              visual = _OptionVisual.idle;
            }
          } else {
            visual = o.id == selected ? _OptionVisual.selected : _OptionVisual.idle;
          }
          return _OptionTile(
            text: o.text,
            visual: visual,
            onTap: answered ? null : () => onSelect(o.id),
          );
        }),
      ],
    );
  }
}

/// Nút loa nhỏ phát âm 1 từ vựng (màn lý thuyết) bằng TtsService dùng chung.
class _VocabSpeakButton extends StatelessWidget {
  const _VocabSpeakButton({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();
    return IconButton(
      visualDensity: VisualDensity.compact,
      // Chỉ NÚT của từ đang đọc mới đổi icon (so theo speakingText), không phải
      // mọi nút cùng nghe isSpeaking chung.
      icon: Obx(() => Icon(
            tts.speakingText.value == text
                ? Icons.graphic_eq_rounded
                : Icons.volume_up_rounded,
            color: AppColors.primary,
          )),
      onPressed: () => tts.speak(text),
    );
  }
}

/// Nút phát audio bằng TtsService dùng chung của app.
class _AudioButton extends StatelessWidget {
  const _AudioButton({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();
    return Center(
      child: Column(
        children: [
          Obx(() {
            final speaking = tts.isSpeaking.value;
            return GestureDetector(
              onTap: () => tts.speak(text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: speaking ? AppColors.primary : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                  size: 34,
                  color: speaking ? AppColors.onPrimaryFixed : AppColors.primary,
                ),
              ),
            );
          }),
          AppGap.h8,
          Text('Chạm để nghe', style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

// ── pronunciation: nghe mẫu + ghi âm (mock) + chấm ──
class _PronunciationBody extends StatelessWidget {
  const _PronunciationBody({
    required this.activity,
    required this.pronounced,
    required this.enabled,
    required this.onPronounced,
  });
  final CurriculumActivity activity;
  final bool pronounced;
  final bool enabled;
  final VoidCallback onPronounced;

  @override
  Widget build(BuildContext context) {
    final target =
        activity.targetText.isNotEmpty ? activity.targetText : activity.question;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: [
              Text(
                target,
                style: AppTypography.headlineMedium.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              if (activity.ipa.isNotEmpty) ...[
                AppGap.h6,
                Text('/${activity.ipa.replaceAll('/', '')}/',
                    style: AppTypography.ipa
                        .copyWith(color: AppColors.tertiary)),
              ],
              AppGap.h12,
              _AudioButton(text: target),
            ],
          ),
        ),
        AppGap.h16,
        // Nút ghi âm (mock — chỉ đánh dấu đã đọc)
        GestureDetector(
          onTap: enabled ? onPronounced : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pronounced ? AppColors.success : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (pronounced ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              pronounced ? Icons.check_rounded : Icons.mic_rounded,
              color: AppColors.onPrimaryFixed,
              size: 34,
            ),
          ),
        ),
        AppGap.h8,
        Text(
          pronounced
              ? 'Đã ghi âm — chấm điểm khi kiểm tra'
              : 'Chạm để ghi âm và đọc theo',
          style: AppTypography.labelSmall.copyWith(
            color: pronounced ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        AppGap.h4,
        Text(
          'Mục tiêu tối thiểu: ${activity.minScoreToPass} điểm',
          style: AppTypography.labelXSmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Thân ghép cặp cho vocabulary_match: mỗi từ bên trái chọn 1 nghĩa từ dropdown.
class _MatchBody extends StatelessWidget {
  const _MatchBody({
    required this.pairs,
    required this.selected,
    required this.enabled,
    required this.onPick,
  });
  final List<MatchPair> pairs;
  final Map<String, String> selected;
  final bool enabled;
  final void Function(String left, String right) onPick;

  @override
  Widget build(BuildContext context) {
    // Các nghĩa để chọn: khử trùng lặp (DropdownButton yêu cầu value duy nhất)
    // rồi trộn theo thứ tự ổn định (không random mỗi lần build → tránh nhảy).
    final options = <String>[];
    for (var i = 0; i < pairs.length; i++) {
      final r = pairs[(i + 1) % pairs.length].right; // xáo lệch 1 bước
      if (r.isNotEmpty && !options.contains(r)) options.add(r);
    }
    return Column(
      children: pairs.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(children: [
            Expanded(
              child: Text(p.left,
                  style: AppTypography.bodyRegular
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 18, color: AppColors.iconMuted),
            AppGap.w8,
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selected[p.left],
                  hint: Text('Chọn nghĩa', style: AppTypography.bodySmall),
                  style: AppTypography.bodyRegular,
                  onChanged: enabled
                      ? (v) {
                          if (v != null) onPick(p.left, v);
                        }
                      : null,
                  items: options
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                ),
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }
}

String _typeLabel(String type) => switch (type) {
      'grammar_fill_blank' => 'Điền từ',
      'vocabulary_match' => 'Ghép cặp',
      'sentence_ordering' => 'Sắp xếp câu',
      'listening_choice' => 'Nghe & chọn',
      'pronunciation' => 'Phát âm',
      'translation' => 'Dịch câu',
      'error_correction' => 'Sửa lỗi',
      _ => 'Trắc nghiệm',
    };

String _difficultyLabel(String d) => switch (d) {
      'easy' => 'Dễ',
      'hard' => 'Khó',
      _ => 'Vừa',
    };

// ─────────────── Luyện tập THÊM với AI (MCQ, chấm local) ───────────────
class _ExtraPracticeView extends StatelessWidget {
  const _ExtraPracticeView({required this.c});
  final LessonPlayerController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Đã làm hết câu → bảng điểm + nút gen tiếp / xong.
      if (c.extraFinished.value) {
        return _ExtraResultPanel(c: c);
      }

      final a = c.currentExtra;
      if (a == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final answered = c.extraAnswered.value;
      final selected = c.extraSelected.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 18, color: AppColors.primary),
                AppGap.w8,
                Text('Luyện thêm',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w900)),
                const Spacer(),
                Text('${c.extraIndex.value + 1}/${c.extraQuestions.length}',
                    style: AppTypography.labelSmall
                        .copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.question,
                      style: AppTypography.bodyRegular
                          .copyWith(fontWeight: FontWeight.w800)),
                  AppGap.h16,
                  ...a.options.map((opt) {
                    final isSelected = selected == opt.id;
                    final isCorrect = opt.id == a.correctOptionId;
                    Color border = AppColors.outlineVariant;
                    Color bg = AppColors.surface;
                    if (answered) {
                      if (isCorrect) {
                        border = AppColors.success;
                        bg = AppColors.success.withValues(alpha: 0.10);
                      } else if (isSelected) {
                        border = AppColors.danger;
                        bg = AppColors.danger.withValues(alpha: 0.10);
                      }
                    } else if (isSelected) {
                      border = AppColors.primary;
                      bg = AppColors.primary.withValues(alpha: 0.08);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap:
                            answered ? null : () => c.selectExtra(opt.id),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: border, width: 1.5),
                          ),
                          child: Text(opt.text,
                              style: AppTypography.bodyRegular),
                        ),
                      ),
                    );
                  }),
                  if (answered && a.explanationVi.isNotEmpty) ...[
                    AppGap.h8,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 20, color: AppColors.primary),
                          AppGap.w12,
                          Expanded(
                            child: Text(a.explanationVi,
                                style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h20,
            AppButton(
              label: answered
                  ? (c.extraIndex.value < c.extraQuestions.length - 1
                      ? 'Câu tiếp'
                      : 'Xem kết quả')
                  : 'Kiểm tra',
              onPressed: answered
                  ? c.nextExtra
                  : (selected == null ? null : c.checkExtra),
              isTranslate: false,
            ),
          ],
        ),
      );
    });
  }
}

class _ExtraResultPanel extends StatelessWidget {
  const _ExtraResultPanel({required this.c});
  final LessonPlayerController c;

  @override
  Widget build(BuildContext context) {
    final score = c.extraScore;
    final correct = c.extraCorrectCount.value;
    final total = c.extraQuestions.length;
    final color = score >= 70 ? AppColors.success : AppColors.tertiary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$correct/$total',
                    style: AppTypography.displayLarge
                        .copyWith(color: color, fontSize: 32, height: 1)),
                Text('ĐÚNG',
                    style: AppTypography.labelXSmall
                        .copyWith(color: color, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          AppGap.h20,
          Text('Hoàn thành luyện thêm!',
              style: AppTypography.headlineMedium.copyWith(color: color)),
          AppGap.h6,
          Text('Bạn trả lời đúng $correct trên $total câu.',
              textAlign: TextAlign.center, style: AppTypography.bodySmall),
          const Spacer(flex: 3),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Xong',
                  onPressed: c.exitExtraPractice,
                  variant: AppButtonVariant.secondary,
                  height: 48,
                  textStyle: AppTypography.bodyRegular
                      .copyWith(fontWeight: FontWeight.w800),
                  isTranslate: false,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Obx(
                  () => AppButton(
                    label: c.isGeneratingExtra.value
                        ? 'Đang tạo...'
                        : 'Gen 5 câu nữa',
                    onPressed: c.isGeneratingExtra.value
                        ? null
                        : c.generateMoreExtra,
                    height: 48,
                    textStyle: AppTypography.bodyRegular
                        .copyWith(fontWeight: FontWeight.w800),
                    isTranslate: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

