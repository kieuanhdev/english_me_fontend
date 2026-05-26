import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/modules/learn/repositories/learning_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class LearningLessonDetailScreen extends StatefulWidget {
  const LearningLessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<LearningLessonDetailScreen> createState() =>
      _LearningLessonDetailScreenState();
}

class _LearningLessonDetailScreenState
    extends State<LearningLessonDetailScreen> {
  late final LearningRepository _repo;
  late Future<LearningLessonDetail> _future;
  late String _lessonId;
  LearningLessonDetail? _lesson;

  // Queue-based activity state
  late List<LearningActivity> _queue; // còn cần làm
  int _currentIndex = 0;             // vị trí trong _queue
  String? _selectedOptionId;         // đáp án đang chọn câu hiện tại
  late TextEditingController _writingController;
  bool _answered = false;            // đã submit câu hiện tại chưa
  bool _currentCorrect = false;      // câu hiện tại đúng hay sai

  // Kết quả tổng hợp sau khi xong tất cả
  final Map<String, bool> _results = {}; // activityId -> isCorrect (lần đầu tiên làm đúng)
  final Set<String> _retryIds = {};      // activityId đã đưa vào retry

  LearningCompleteResponse? _completion;
  bool _submitting = false;
  bool _loadingNext = false;
  bool _levelUpPromptShown = false;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _repo = Get.find<LearningRepository>();
    _lessonId = widget.lessonId;
    _writingController = TextEditingController();
    _future = _repo.getLessonDetail(_lessonId);
  }

  void _initQueue(LearningLessonDetail lesson) {
    _queue = List.of(lesson.activities);
    _currentIndex = 0;
    _selectedOptionId = null;
    _writingController.clear();
    _answered = false;
    _currentCorrect = false;
    _results.clear();
    _retryIds.clear();
  }

  @override
  void dispose() {
    _writingController.dispose();
    super.dispose();
  }

  LearningActivity? get _currentActivity =>
      _queue.isEmpty ? null : _queue[_currentIndex];

  bool get _allDone => _queue.isEmpty;

  // Số câu còn lại (tính câu hiện tại)
  int get _remaining => _queue.length - _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FutureBuilder<LearningLessonDetail>(
          future: _future,
          builder: (context, snapshot) {
            final lesson = _lesson ?? snapshot.data;
            final state = lesson != null
                ? ApiState.success
                : snapshot.connectionState == ConnectionState.waiting
                ? ApiState.loading
                : snapshot.hasError
                ? ApiState.error
                : snapshot.data == null
                ? ApiState.empty
                : ApiState.success;

            if (lesson != null && _queue.isEmpty && _completion == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _queue.isEmpty && _completion == null) {
                  setState(() => _initQueue(lesson));
                }
              });
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ApiStateView(
                state: state,
                errorMessage: 'Không tải được bài học.',
                emptyMessage: 'Không tìm thấy bài học.',
                onRetry: () => setState(() {
                  _lesson = null;
                  _future = _repo.getLessonDetail(_lessonId);
                }),
                builder: (_) {
                  if (_completion != null) {
                    return _CompletionView(
                      lesson: lesson!,
                      result: _completion!,
                      loadingNext: _loadingNext,
                      onContinue: _continueAfterComplete,
                    );
                  }
                  if (_allDone) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _QuizView(
                    lesson: lesson!,
                    activity: _currentActivity!,
                    selectedOptionId: _selectedOptionId,
                    writingController: _writingController,
                    answered: _answered,
                    currentCorrect: _currentCorrect,
                    remaining: _remaining,
                    totalOriginal: lesson.activities.length,
                    submitting: _submitting,
                    onSelectOption: _answered
                        ? null
                        : (id) => setState(() => _selectedOptionId = id),
                    onConfirm: _answered ? _nextActivity : _confirmAnswer,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmAnswer() {
    final activity = _currentActivity;
    if (activity == null) return;

    bool correct;
    if (activity.type == 'multiple_choice') {
      if (_selectedOptionId == null) {
        _showTopNotice(
          title: 'Chưa chọn đáp án',
          message: 'Hãy chọn một đáp án trước khi tiếp tục.',
          isError: true,
        );
        return;
      }
      correct = _selectedOptionId == activity.correctOptionId;
    } else if (activity.type == 'writing_prompt') {
      correct = _writingController.text.trim().isNotEmpty;
    } else {
      correct = true; // pronunciation và các loại khác tự tính đúng
    }

    // Chỉ ghi nhận kết quả lần đầu tiên gặp câu này
    if (!_retryIds.contains(activity.id)) {
      _results[activity.id] = correct;
    }

    setState(() {
      _answered = true;
      _currentCorrect = correct;
    });
  }

  void _nextActivity() {
    final activity = _currentActivity;
    if (activity == null) return;

    if (!_currentCorrect && !_retryIds.contains(activity.id)) {
      // Câu sai lần đầu: đẩy xuống cuối queue để làm lại
      _retryIds.add(activity.id);
      _queue.add(activity);
    }

    // Chuyển sang câu kế
    final nextIndex = _currentIndex + 1;

    if (nextIndex >= _queue.length) {
      // Hết queue → submit
      _submitLesson();
      return;
    }

    setState(() {
      _currentIndex = nextIndex;
      _selectedOptionId = null;
      _writingController.clear();
      _answered = false;
      _currentCorrect = false;
    });
  }

  Future<void> _submitLesson() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final lesson = _lesson ?? (await _future);
    final totalOriginal = lesson.activities.length;

    // Tính score dựa trên số câu gốc làm đúng ngay lần đầu
    final correctCount = _results.values.where((v) => v).length;
    final score = totalOriginal == 0
        ? 100
        : ((correctCount / totalOriginal) * 100).round();

    // Build answers array (chỉ lấy câu gốc, không lặp lại retry)
    final answers = <Map<String, dynamic>>[];
    for (final activity in lesson.activities) {
      final isCorrect = _results[activity.id] ?? false;
      if (activity.type == 'multiple_choice') {
        answers.add({
          'activityId': activity.id,
          'type': activity.type,
          'isCorrect': isCorrect,
        });
      } else if (activity.type == 'writing_prompt') {
        answers.add({
          'activityId': activity.id,
          'type': activity.type,
          'isCorrect': isCorrect,
        });
      } else {
        answers.add({
          'activityId': activity.id,
          'type': activity.type,
          'isCorrect': isCorrect,
        });
      }
    }

    try {
      final result = await _repo.completeLesson(
        lessonId: lesson.id,
        score: score,
        timeSpentSeconds: lesson.durationMinutes * 60,
        answers: answers,
      );
      XpGrantHandler.apply(
        totalXp: result.totalXp,
        xpEarned: result.xpEarned,
        streakUpdated: result.streakUpdated,
        bonuses: result.bonuses,
      );
      if (mounted) {
        _hasCompleted = true;
        setState(() {
          _completion = result;
          _submitting = false;
        });
        if (result.completed && result.levelProgress >= 1) {
          _showLevelUpPrompt();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        _showTopNotice(
          title: 'Không lưu được kết quả',
          message: 'Vui lòng thử lại.',
          isError: true,
        );
      }
    }
  }

  void _closeToList() {
    if (!mounted) return;
    if (Get.key.currentState?.canPop() == true) {
      Get.back(result: _hasCompleted);
    }
  }

  Future<void> _continueAfterComplete() async {
    if (_loadingNext) return;
    final nextLessonId = _completion?.nextLessonId;
    if (nextLessonId == null || nextLessonId.trim().isEmpty) {
      _closeToList();
      return;
    }
    setState(() => _loadingNext = true);
    try {
      final nextLesson = await _repo.getLessonDetail(nextLessonId);
      if (!mounted) return;
      setState(() {
        _lessonId = nextLessonId;
        _lesson = nextLesson;
        _completion = null;
        _submitting = false;
        _loadingNext = false;
        _future = Future.value(nextLesson);
        _initQueue(nextLesson);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingNext = false);
      _showTopNotice(
        title: 'Không tải được câu tiếp theo',
        message: 'Vui lòng thử lại.',
        isError: true,
      );
    }
  }

  Future<void> _showLevelUpPrompt() async {
    if (_levelUpPromptShown) return;
    _levelUpPromptShown = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final goToTest = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hoàn thành level'),
        content: const Text(
          'Bạn đã học xong level này. Bạn có muốn làm bài kiểm tra để nâng level không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đi kiểm tra'),
          ),
        ],
      ),
    );

    if (goToTest == true) {
      Get.toNamed(AppRoutes.placementTest);
    }
  }

  void _showTopNotice({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      borderRadius: AppRadius.md,
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      colorText: AppColors.onPrimaryFixed,
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
        color: AppColors.onPrimaryFixed,
      ),
      duration: const Duration(seconds: 2),
      shouldIconPulse: false,
    );
  }
}

// ─── Quiz view: hiển thị 1 câu tại một thời điểm ─────────────────────────────

class _QuizView extends StatelessWidget {
  const _QuizView({
    required this.lesson,
    required this.activity,
    required this.selectedOptionId,
    required this.writingController,
    required this.answered,
    required this.currentCorrect,
    required this.remaining,
    required this.totalOriginal,
    required this.submitting,
    required this.onSelectOption,
    required this.onConfirm,
  });

  final LearningLessonDetail lesson;
  final LearningActivity activity;
  final String? selectedOptionId;
  final TextEditingController writingController;
  final bool answered;
  final bool currentCorrect;
  final int remaining;
  final int totalOriginal;
  final bool submitting;
  final ValueChanged<String>? onSelectOption;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final color = _skillColor(lesson.skill);
    String buttonLabel;
    if (submitting) {
      buttonLabel = 'Đang lưu...';
    } else if (!answered) {
      buttonLabel = 'Xác nhận';
    } else if (currentCorrect) {
      buttonLabel = remaining > 1 ? 'Câu tiếp theo' : 'Nộp bài';
    } else {
      buttonLabel = remaining > 1 ? 'Câu tiếp theo' : 'Nộp bài';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppMainAppBar(
          title: lesson.title,
          showBack: true,
          showSettings: false,
          showNotification: false,
          horizontalPadding: 0,
          onBack: Get.back,
        ),
        AppGap.h12,
        _ProgressBar(remaining: remaining, total: totalOriginal),
        AppGap.h12,
        Expanded(
          child: ListView(
            children: [
              _LessonHeader(lesson: lesson, color: color),
              AppGap.h14,
              _ContentCard(lesson: lesson, color: color),
              AppGap.h14,
              _ActivityRenderer(
                activity: activity,
                selectedOptionId: selectedOptionId,
                answered: answered,
                writingController: writingController,
                onSelectOption: onSelectOption,
              ),
              if (answered) ...[
                AppGap.h12,
                _AnswerFeedback(
                  correct: currentCorrect,
                  isRetry: false,
                  explanationVi: activity.type == 'multiple_choice'
                      ? activity.explanationVi
                      : null,
                ),
              ],
            ],
          ),
        ),
        AppGap.h12,
        AppButton(
          label: buttonLabel,
          onPressed: submitting ? null : onConfirm,
          isTranslate: false,
        ),
      ],
    );
  }
}

// ─── Progress bar câu ────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final done = total - remaining;
    final progress = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        AppGap.w10,
        Text(
          '$done/$total',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ─── Feedback đúng / sai sau khi xác nhận ────────────────────────────────────

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    required this.correct,
    required this.isRetry,
    this.explanationVi,
  });

  final bool correct;
  final bool isRetry;
  final String? explanationVi;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.danger;
    final bgColor = correct ? AppColors.successSoft : AppColors.dangerSoft;
    final icon = correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = correct
        ? 'Chính xác!'
        : isRetry
        ? 'Vẫn chưa đúng — hãy ghi nhớ đáp án đúng'
        : 'Chưa đúng — câu này sẽ xuất hiện lại cuối bài';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              AppGap.w8,
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          if (explanationVi != null && explanationVi!.isNotEmpty) ...[
            AppGap.h8,
            Text(
              explanationVi!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Completion view sau khi nộp bài ─────────────────────────────────────────

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.lesson,
    required this.result,
    required this.loadingNext,
    required this.onContinue,
  });

  final LearningLessonDetail lesson;
  final LearningCompleteResponse result;
  final bool loadingNext;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final color = _skillColor(lesson.skill);
    final buttonLabel = loadingNext
        ? 'Đang tải...'
        : result.nextLessonId?.trim().isNotEmpty == true
        ? 'Câu tiếp theo'
        : 'Hoàn thành';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppMainAppBar(
          title: lesson.title,
          showBack: true,
          showSettings: false,
          showNotification: false,
          horizontalPadding: 0,
          onBack: Get.back,
        ),
        AppGap.h16,
        Expanded(
          child: ListView(
            children: [
              _LessonHeader(lesson: lesson, color: color),
              AppGap.h20,
              _ResultCard(result: result),
            ],
          ),
        ),
        AppGap.h12,
        AppButton(
          label: buttonLabel,
          onPressed: loadingNext ? null : onContinue,
          isTranslate: false,
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final LearningCompleteResponse result;

  @override
  Widget build(BuildContext context) {
    final passed = result.completed;
    final color = passed ? AppColors.success : AppColors.tertiary;
    final bgColor = passed ? AppColors.successSoft : AppColors.recommendationOrangeBg;
    final icon = passed ? Icons.emoji_events_rounded : Icons.replay_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          AppGap.h12,
          Text(
            passed ? 'Hoàn thành!' : 'Cần luyện thêm',
            style: AppTypography.headlineMedium.copyWith(color: color),
          ),
          AppGap.h8,
          Text(
            '${result.score} điểm • +${result.xpEarned} XP',
            style: AppTypography.bodyRegular.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (result.bonuses.isNotEmpty) ...[
            AppGap.h8,
            ...result.bonuses.map(
              (b) => Text(
                '${b.label} +${b.amount} XP',
                style: AppTypography.bodySmall.copyWith(color: color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Lesson header / Content card / Activity renderer (không đổi logic) ──────

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.lesson, required this.color});

  final LearningLessonDetail lesson;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(_skillIcon(lesson.skill), color: color, size: 28),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lesson.level} • ${_skillLabel(lesson.skill)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                AppGap.h2,
                Text(lesson.subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Text(
            '+${lesson.xpReward} XP',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.lesson, required this.color});

  final LearningLessonDetail lesson;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final content = lesson.content;
    final lines = <Widget>[
      _ContentLine(title: 'Hướng dẫn', value: content['instruction']?.toString()),
      _ContentLine(title: 'Bài đọc', value: content['passage']?.toString()),
      _ContentLine(title: 'Câu mẫu', value: content['sampleText']?.toString()),
      _ContentLine(title: 'Phiên âm', value: content['phonetic']?.toString()),
      _ContentLine(title: 'Đề bài', value: content['prompt']?.toString()),
      _ContentLine(title: 'Bài mẫu', value: content['exampleAnswer']?.toString()),
      _ContentLine(title: 'Transcript', value: content['transcript']?.toString()),
      _ContentLine(title: 'Nghĩa tiếng Việt', value: content['translationVi']?.toString()),
    ].where((w) => w is _ContentLine && w.value?.trim().isNotEmpty == true).toList();

    if (lines.isEmpty && content['audioUrl'] == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContentLine(title: 'Hướng dẫn', value: content['instruction']?.toString()),
          _ContentLine(title: 'Bài đọc', value: content['passage']?.toString()),
          _ContentLine(title: 'Câu mẫu', value: content['sampleText']?.toString()),
          _ContentLine(title: 'Phiên âm', value: content['phonetic']?.toString()),
          _ContentLine(title: 'Đề bài', value: content['prompt']?.toString()),
          _ContentLine(title: 'Bài mẫu', value: content['exampleAnswer']?.toString()),
          _ContentLine(title: 'Transcript', value: content['transcript']?.toString()),
          _ContentLine(title: 'Nghĩa tiếng Việt', value: content['translationVi']?.toString()),
          if (content['audioUrl'] != null) ...[
            AppGap.h8,
            Row(
              children: [
                Icon(Icons.volume_up_rounded, color: color, size: 18),
                AppGap.w8,
                Expanded(
                  child: Text(
                    content['audioUrl'].toString(),
                    style: AppTypography.bodySmall.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContentLine extends StatelessWidget {
  const _ContentLine({required this.title, required this.value});

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          AppGap.h2,
          Text(value!, style: AppTypography.bodyRegular),
        ],
      ),
    );
  }
}

class _ActivityRenderer extends StatelessWidget {
  const _ActivityRenderer({
    required this.activity,
    required this.selectedOptionId,
    required this.answered,
    required this.writingController,
    required this.onSelectOption,
  });

  final LearningActivity activity;
  final String? selectedOptionId;
  final bool answered;
  final TextEditingController writingController;
  final ValueChanged<String>? onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: switch (activity.type) {
        'multiple_choice' => _MultipleChoiceActivity(
          activity: activity,
          selectedOptionId: selectedOptionId,
          answered: answered,
          onSelectOption: onSelectOption,
        ),
        'writing_prompt' => _WritingActivity(
          activity: activity,
          controller: writingController,
          answered: answered,
        ),
        'pronunciation' => _PronunciationActivity(activity: activity),
        _ => Text(
          'Loại bài tập: ${activity.type}',
          style: AppTypography.bodyRegular,
        ),
      },
    );
  }
}

class _MultipleChoiceActivity extends StatelessWidget {
  const _MultipleChoiceActivity({
    required this.activity,
    required this.selectedOptionId,
    required this.answered,
    required this.onSelectOption,
  });

  final LearningActivity activity;
  final String? selectedOptionId;
  final bool answered;
  final ValueChanged<String>? onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activity.question, style: AppTypography.bodyRegular),
        AppGap.h12,
        ...activity.options.map((option) {
          final isSelected = selectedOptionId == option.id;
          final isCorrect = activity.correctOptionId == option.id;
          final showCorrect = answered && isCorrect;
          final showWrong = answered && isSelected && !isCorrect;
          final bgColor = showCorrect
              ? AppColors.successSoft
              : showWrong
              ? AppColors.dangerSoft
              : isSelected
              ? AppColors.primarySoftSelected
              : AppColors.surfaceContainerLow;
          final borderColor = showCorrect
              ? AppColors.success
              : showWrong
              ? AppColors.danger
              : isSelected
              ? AppColors.primary
              : AppColors.outlineVariant;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: answered ? null : () => onSelectOption?.call(option.id),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Text(
                      option.id,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppGap.w10,
                    Expanded(
                      child: Text(option.text, style: AppTypography.bodyRegular),
                    ),
                    if (showCorrect)
                      Icon(Icons.check_circle_rounded, color: AppColors.success)
                    else if (showWrong)
                      Icon(Icons.cancel_rounded, color: AppColors.danger),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _WritingActivity extends StatelessWidget {
  const _WritingActivity({
    required this.activity,
    required this.controller,
    required this.answered,
  });

  final LearningActivity activity;
  final TextEditingController controller;
  final bool answered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activity.prompt, style: AppTypography.bodyRegular),
        AppGap.h12,
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          enabled: !answered,
          decoration: const InputDecoration(hintText: 'Nhập câu trả lời...'),
        ),
        if (activity.rubric.isNotEmpty) ...[
          AppGap.h12,
          ...activity.rubric.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  AppGap.w8,
                  Expanded(child: Text(item, style: AppTypography.bodySmall)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PronunciationActivity extends StatelessWidget {
  const _PronunciationActivity({required this.activity});

  final LearningActivity activity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.expectedText,
          style: AppTypography.headlineMedium.copyWith(fontSize: 18),
        ),
        AppGap.h8,
        Text(
          'Mục tiêu tối thiểu: ${activity.minScoreToPass} điểm.',
          style: AppTypography.bodySmall,
        ),
        AppGap.h12,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.recommendationOrangeBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.mic_rounded, color: AppColors.tertiary),
              AppGap.w10,
              Expanded(
                child: Text(
                  'Ghi âm sẽ được triển khai ở bước nối flow pronunciation.',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

IconData _skillIcon(String skill) {
  return switch (skill) {
    'listening' => Icons.headphones_rounded,
    'speaking' => Icons.record_voice_over_rounded,
    'reading' => Icons.article_rounded,
    'writing' => Icons.edit_note_rounded,
    _ => Icons.school_rounded,
  };
}

String _skillLabel(String skill) {
  return switch (skill) {
    'listening' => 'Nghe',
    'speaking' => 'Nói',
    'reading' => 'Đọc',
    'writing' => 'Viết',
    _ => skill,
  };
}

Color _skillColor(String skill) {
  return switch (skill) {
    'listening' => AppColors.skillListening,
    'speaking' => AppColors.tertiary,
    'reading' => AppColors.success,
    'writing' => AppColors.primary,
    _ => AppColors.primary,
  };
}
