import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';
import 'package:englishme/modules/pronunciation/controllers/pronunciation_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key});

  void _onBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
      return;
    }
    ShellController.goToTab(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(
                title: T.pronunTitle.tr,
                showBack: true,
                horizontalPadding: 0,
                onBack: _onBack,
              ),
              AppGap.h24,
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return GetX<PronunciationController>(
      builder: (ctrl) {
        if (ctrl.isLoadingExercises.value) {
          return ApiStateView(
            state: ApiState.loading,
            builder: (_) => const SizedBox.shrink(),
          );
        }

        if (ctrl.selectedExercise.value == null) {
          return _buildExerciseList(ctrl);
        }

        return _buildRecordingPanel(ctrl);
      },
    );
  }

  Widget _buildExerciseList(PronunciationController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.pronunChooseExercise.tr,
          style: AppTypography.headlineMedium.copyWith(fontSize: 20),
        ),
        AppGap.h12,
        _SearchBox(ctrl: ctrl),
        AppGap.h12,
        _LevelFilterBar(ctrl: ctrl),
        AppGap.h12,
        _InsightEntry(onTap: () => Get.toNamed(AppRoutes.pronunciationInsight)),
        AppGap.h12,
        Expanded(
          child: ctrl.exercises.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  itemCount: ctrl.exercises.length,
                  separatorBuilder: (_, __) => AppGap.h10,
                  itemBuilder: (context, index) {
                    final exercise = ctrl.exercises[index];
                    return _ExerciseCard(
                      exercise: exercise,
                      onTap: () => ctrl.selectExercise(exercise),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
          AppGap.h16,
          Text(
            T.emptyExercises.tr,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingPanel(PronunciationController ctrl) {
    final exercise = ctrl.selectedExercise.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _ExercisePromptCard(exercise: exercise),
          AppGap.h20,
          _RecordButton(ctrl: ctrl),
          AppGap.h12,
          _RecordHint(ctrl: ctrl),
          if (ctrl.liveTranscript.value.isNotEmpty) ...[
            AppGap.h16,
            _TranscriptCard(ctrl: ctrl),
          ],
          AppGap.h16,
          if (ctrl.canGoToResult.value && !ctrl.isRecording.value)
            _AnalyzeButton(ctrl: ctrl),
          if (ctrl.isAssessing.value) ...[
            AppGap.h16,
            CircularProgressIndicator(color: AppColors.primary),
          ],
          if (ctrl.feedback.value != null) ...[
            AppGap.h16,
            _QuickScorePreview(feedback: ctrl.feedback.value!),
            AppGap.h12,
            _ViewDetailButton(ctrl: ctrl),
          ],
        ],
      ),
    );
  }
}

Color _levelColor(String level) {
  switch (level.toUpperCase()) {
    case 'A1':
    case 'A2':
      return AppColors.success;
    case 'B1':
    case 'B2':
      return AppColors.tertiary;
    case 'C1':
    case 'C2':
      return AppColors.danger;
    default:
      return AppColors.primary;
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: ctrl.onSearchChanged,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: T.pronunSearchHint.tr,
        prefixIcon: Icon(Icons.search, color: AppColors.iconMuted),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _LevelFilterBar extends StatelessWidget {
  const _LevelFilterBar({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Obx(() {
        final selected = ctrl.selectedLevel.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: PronunciationController.levelFilters.length,
          separatorBuilder: (_, __) => AppGap.w8,
          itemBuilder: (context, index) {
            final level = PronunciationController.levelFilters[index];
            final isSelected = selected == level;
            final label = level.isEmpty ? T.pronunFilterAll.tr : level;
            final color = level.isEmpty ? AppColors.primary : _levelColor(level);
            return GestureDetector(
              onTap: () => ctrl.setLevelFilter(level),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? color : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? color : AppColors.outlineVariant,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.onPrimaryFixed : color,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        level.toUpperCase(),
        style: AppTypography.body.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final PronunciationExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.record_voice_over, color: AppColors.primary),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (exercise.level != null) ...[
                          _LevelBadge(level: exercise.level!),
                          AppGap.w8,
                        ],
                        Expanded(
                          child: Text(
                            exercise.text,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (exercise.phonetic != null) ...[
                      AppGap.h6,
                      Text(
                        '/${exercise.phonetic}/',
                        style: AppTypography.ipa.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExercisePromptCard extends StatelessWidget {
  const _ExercisePromptCard({required this.exercise});

  final PronunciationExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final speaking = Get.find<TtsService>().isSpeaking.value;
            return GestureDetector(
              onTap: () => Get.find<TtsService>().speak(exercise.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: speaking ? AppColors.primary : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  size: 24,
                  color: speaking
                      ? AppColors.onPrimaryFixed
                      : AppColors.primary,
                ),
              ),
            );
          }),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.text,
                  style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                ),
                if (exercise.phonetic != null) ...[
                  AppGap.h4,
                  Text(
                    '/${exercise.phonetic}/',
                    style: AppTypography.ipa.copyWith(
                      color: AppColors.tertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (exercise.meaning != null) ...[
                  AppGap.h4,
                  Text(
                    exercise.meaning!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recording = ctrl.isRecording.value;

      return GestureDetector(
        onTap: recording ? ctrl.stopRecording : ctrl.startRecording,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: recording ? AppColors.danger : AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: (recording ? AppColors.danger : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: recording ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            recording ? Icons.stop : Icons.mic,
            color: AppColors.onPrimaryFixed,
            size: 30,
          ),
        ),
      );
    });
  }
}

class _RecordHint extends StatelessWidget {
  const _RecordHint({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recording = ctrl.isRecording.value;
      return Text(
        recording ? T.pronunListening.tr : T.pronunTapToSpeak.tr,
        style: AppTypography.body.copyWith(
          fontSize: 14,
          fontWeight: recording ? FontWeight.w700 : FontWeight.w500,
          color: recording ? AppColors.danger : AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      );
    });
  }
}

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final text = ctrl.liveTranscript.value;
      final recording = ctrl.isRecording.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: recording ? AppColors.danger : AppColors.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  size: 18,
                  color: recording ? AppColors.danger : AppColors.primary,
                ),
                AppGap.w8,
                Text(
                  T.pronunYouSaid.tr,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            AppGap.h10,
            Text(
              text,
              style: AppTypography.headlineMedium.copyWith(fontSize: 20),
            ),
          ],
        ),
      );
    });
  }
}

class _AnalyzeButton extends StatelessWidget {
  const _AnalyzeButton({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: T.pronunAnalysis,
      onPressed: ctrl.isAssessing.value ? null : ctrl.assessRecording,
      leading: const Icon(Icons.analytics_outlined),
    );
  }
}

class _QuickScorePreview extends StatelessWidget {
  const _QuickScorePreview({required this.feedback});

  final PronunciationFeedback feedback;

  Color _scoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.tertiary;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: feedback.score / 100,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _scoreColor(feedback.score),
                  ),
                ),
                Text(
                  '${feedback.score.round()}',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 18,
                    color: _scoreColor(feedback.score),
                  ),
                ),
              ],
            ),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  T.pronunScore.tr,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppGap.h6,
                Text(
                  feedback.overallComment ?? T.pronunSeeDetailBelow.tr,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewDetailButton extends StatelessWidget {
  const _ViewDetailButton({required this.ctrl});

  final PronunciationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: T.actionViewDetail,
      variant: AppButtonVariant.secondary,
      onPressed: () => Get.toNamed(AppRoutes.pronunciationResult),
      leading: const Icon(Icons.visibility_outlined),
    );
  }
}

/// Lối vào màn "Điểm yếu phát âm" (P4) — tổng hợp lịch sử luyện của user.
class _InsightEntry extends StatelessWidget {
  const _InsightEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tertiary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.insights_rounded, color: AppColors.tertiary, size: 22),
              AppGap.w12,
              Expanded(
                child: Text(
                  'Xem điểm yếu phát âm của bạn',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.tertiary),
            ],
          ),
        ),
      ),
    );
  }
}
