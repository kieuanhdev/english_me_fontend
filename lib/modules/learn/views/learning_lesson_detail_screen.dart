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
  final Map<String, String> _selectedOptions = {};
  final Map<String, TextEditingController> _writingControllers = {};
  LearningCompleteResponse? _completion;
  bool _submitting = false;
  bool _loadingNext = false;
  bool _levelUpPromptShown = false;

  @override
  void initState() {
    super.initState();
    _repo = Get.find<LearningRepository>();
    _lessonId = widget.lessonId;
    _future = _repo.getLessonDetail(_lessonId);
  }

  @override
  void dispose() {
    for (final controller in _writingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
                builder: (_) => _LessonBody(
                  lesson: lesson!,
                  selectedOptions: _selectedOptions,
                  writingControllers: _writingControllers,
                  completion: _completion,
                  submitting: _submitting,
                  loadingNext: _loadingNext,
                  onSelectOption: (activityId, optionId) {
                    if (_completion != null) return;
                    setState(() => _selectedOptions[activityId] = optionId);
                  },
                  onComplete: () => _complete(lesson),
                  onContinue: _continueAfterComplete,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _closeToList() {
    if (!mounted) return;
    if (Get.key.currentState?.canPop() == true) {
      Get.back(result: true);
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
      for (final controller in _writingControllers.values) {
        controller.dispose();
      }
      _writingControllers.clear();
      _selectedOptions.clear();
      setState(() {
        _lessonId = nextLessonId;
        _lesson = nextLesson;
        _completion = null;
        _submitting = false;
        _loadingNext = false;
        _future = Future.value(nextLesson);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingNext = false);
      _showTopNotice(
        title: 'Cannot load next question',
        message: 'Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _complete(LearningLessonDetail lesson) async {
    if (_submitting) return;
    if (_completion != null) {
      _continueAfterComplete();
      return;
    }
    final missingAnswer = lesson.activities.any((activity) {
      if (activity.type == 'multiple_choice') {
        return _selectedOptions[activity.id] == null;
      }
      if (activity.type == 'writing_prompt') {
        return (_writingControllers[activity.id]?.text.trim() ?? '').isEmpty;
      }
      return false;
    });
    if (missingAnswer) {
      _showTopNotice(
        title: 'Answer required',
        message: 'Please answer this question before continuing.',
        isError: true,
      );
      return;
    }
    setState(() => _submitting = true);
    final answers = <Map<String, dynamic>>[];
    var correct = 0;
    for (final activity in lesson.activities) {
      if (activity.type == 'multiple_choice') {
        final selected = _selectedOptions[activity.id];
        final isCorrect =
            selected != null && selected == activity.correctOptionId;
        if (isCorrect) correct++;
        answers.add({
          'activityId': activity.id,
          'type': activity.type,
          'selectedOptionId': selected,
          'isCorrect': isCorrect,
        });
      } else if (activity.type == 'writing_prompt') {
        final text = _writingControllers[activity.id]?.text.trim() ?? '';
        final isCorrect = text.isNotEmpty;
        if (isCorrect) correct++;
        answers.add({
          'activityId': activity.id,
          'type': activity.type,
          'textAnswer': text,
          'isCorrect': isCorrect,
        });
      } else {
        correct++;
        answers.add({
          'activityId': activity.id,
          'type': activity.type,
          'isCorrect': true,
        });
      }
    }
    final total = lesson.activities.isEmpty ? 1 : lesson.activities.length;
    final score = ((correct / total) * 100).round();
    try {
      final result = await _repo.completeLesson(
        lessonId: lesson.id,
        score: score,
        timeSpentSeconds: lesson.durationMinutes * 60,
        answers: answers,
      );
      _showTopNotice(
        title: 'Question completed',
        message: '+${result.xpEarned} XP - ${result.score} points',
      );
      // Spec §9.5: set thẳng totalXp vào ProfileController; show bonuses toast.
      XpGrantHandler.apply(
        totalXp: result.totalXp,
        xpEarned: result.xpEarned,
        streakUpdated: result.streakUpdated,
        bonuses: result.bonuses,
      );
      if (mounted) {
        setState(() => _completion = result);
        if (result.completed && result.levelProgress >= 1) {
          _showLevelUpPrompt();
        }
      }
    } catch (_) {
      _showTopNotice(
        title: 'Cannot save result',
        message: 'Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
    final background = isError ? AppColors.danger : AppColors.success;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      borderRadius: AppRadius.md,
      backgroundColor: background,
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

class _LessonBody extends StatelessWidget {
  const _LessonBody({
    required this.lesson,
    required this.selectedOptions,
    required this.writingControllers,
    required this.completion,
    required this.submitting,
    required this.loadingNext,
    required this.onSelectOption,
    required this.onComplete,
    required this.onContinue,
  });

  final LearningLessonDetail lesson;
  final Map<String, String> selectedOptions;
  final Map<String, TextEditingController> writingControllers;
  final LearningCompleteResponse? completion;
  final bool submitting;
  final bool loadingNext;
  final void Function(String activityId, String optionId) onSelectOption;
  final VoidCallback onComplete;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final color = _skillColor(lesson.skill);
    final completionButtonLabel = loadingNext
        ? 'Đang tải câu tiếp theo...'
        : completion?.nextLessonId?.trim().isNotEmpty == true
        ? 'Câu tiếp theo'
        : 'Hoàn thành path';
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
              AppGap.h14,
              _ContentCard(lesson: lesson, color: color),
              AppGap.h14,
              ...lesson.activities.map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityRenderer(
                    activity: activity,
                    selectedOptionId: selectedOptions[activity.id],
                    revealAnswer: completion != null,
                    writingController: writingControllers.putIfAbsent(
                      activity.id,
                      TextEditingController.new,
                    ),
                    onSelectOption: (optionId) =>
                        onSelectOption(activity.id, optionId),
                  ),
                ),
              ),
              if (completion != null) ...[
                AppGap.h4,
                _CompletionCard(result: completion!),
              ],
            ],
          ),
        ),
        AppGap.h12,
        if (completion != null)
          AppButton(
            label: completionButtonLabel,
            onPressed: loadingNext ? null : onContinue,
            isTranslate: false,
          )
        else
          AppButton(
            label: submitting ? 'Đang lưu...' : 'Hoàn thành',
            onPressed: submitting
                ? null
                : completion != null
                ? onContinue
                : onComplete,
            isTranslate: false,
          ),
      ],
    );
  }
}

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
          _ContentLine(
            title: 'Hướng dẫn',
            value: content['instruction']?.toString(),
          ),
          _ContentLine(title: 'Bài đọc', value: content['passage']?.toString()),
          _ContentLine(
            title: 'Câu mẫu',
            value: content['sampleText']?.toString(),
          ),
          _ContentLine(
            title: 'Phiên âm',
            value: content['phonetic']?.toString(),
          ),
          _ContentLine(title: 'Đề bài', value: content['prompt']?.toString()),
          _ContentLine(
            title: 'Bài mẫu',
            value: content['exampleAnswer']?.toString(),
          ),
          _ContentLine(
            title: 'Transcript',
            value: content['transcript']?.toString(),
          ),
          _ContentLine(
            title: 'Nghĩa tiếng Việt',
            value: content['translationVi']?.toString(),
          ),
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
    required this.revealAnswer,
    required this.writingController,
    required this.onSelectOption,
  });

  final LearningActivity activity;
  final String? selectedOptionId;
  final bool revealAnswer;
  final TextEditingController writingController;
  final ValueChanged<String> onSelectOption;

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
          revealAnswer: revealAnswer,
          onSelectOption: onSelectOption,
        ),
        'writing_prompt' => _WritingActivity(
          activity: activity,
          controller: writingController,
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
    required this.revealAnswer,
    required this.onSelectOption,
  });

  final LearningActivity activity;
  final String? selectedOptionId;
  final bool revealAnswer;
  final ValueChanged<String> onSelectOption;

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
          final showCorrect = revealAnswer && isCorrect;
          final showWrong = revealAnswer && isSelected && !isCorrect;
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
              onTap: revealAnswer ? null : () => onSelectOption(option.id),
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
                      child: Text(
                        option.text,
                        style: AppTypography.bodyRegular,
                      ),
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
        if (revealAnswer && activity.explanationVi.isNotEmpty) ...[
          AppGap.h8,
          Text(
            activity.explanationVi,
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
          ),
        ],
      ],
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.result});

  final LearningCompleteResponse result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã lưu kết quả',
                  style: AppTypography.bodyRegular.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
                AppGap.h2,
                Text(
                  '${result.score} điểm • +${result.xpEarned} XP',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingActivity extends StatelessWidget {
  const _WritingActivity({required this.activity, required this.controller});

  final LearningActivity activity;
  final TextEditingController controller;

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
          'Mục tiêu tối thiểu: ${activity.minScoreToPass} điểm. Phần ghi âm/chấm phát âm sẽ nối với module pronunciation hiện có.',
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
