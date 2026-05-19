import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/core/widgets/app_settings_icon_button.dart';
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
    ShellController.goToTab(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: AppBottomNav(
        initialIndex: 1,
        onTap: (index, _) => ShellController.goToTab(index),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: _onBack),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      T.pronunTitle.tr,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const AppSettingsIconButton(),
                ],
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
    if (ctrl.exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_off_outlined, size: 48, color: AppColors.textSecondary),
            AppGap.h16,
            Text(
              T.emptyExercises.tr,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.pronunChooseExercise.tr,
          style: AppTypography.headlineMedium.copyWith(fontSize: 20),
        ),
        AppGap.h12,
        Expanded(
          child: ListView.separated(
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

  Widget _buildRecordingPanel(PronunciationController ctrl) {
    final exercise = ctrl.selectedExercise.value!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppGap.h8,
          _ExercisePromptCard(exercise: exercise),
          AppGap.h32,
          _RecordButton(ctrl: ctrl),
          AppGap.h24,
          if (ctrl.recordedFilePath.value != null && !ctrl.isRecording.value)
            _AnalyzeButton(ctrl: ctrl),
          if (ctrl.isAssessing.value) ...[
            AppGap.h20,
            CircularProgressIndicator(color: AppColors.primary),
          ],
          if (ctrl.feedback.value != null) ...[
            AppGap.h20,
            _QuickScorePreview(feedback: ctrl.feedback.value!),
            AppGap.h16,
            _ViewDetailButton(ctrl: ctrl),
          ],
        ],
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
                    Text(
                      exercise.text,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (exercise.phonetic != null) ...[
                      AppGap.h6,
                      Text(
                        '/${exercise.phonetic}/',
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Obx(() {
            final speaking = Get.find<TtsService>().isSpeaking.value;
            return GestureDetector(
              onTap: () => Get.find<TtsService>().speak(exercise.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: speaking ? AppColors.primary : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  speaking ? Icons.volume_up_rounded : Icons.volume_up_rounded,
                  size: 28,
                  color: speaking ? AppColors.onPrimaryFixed : AppColors.primary,
                ),
              ),
            );
          }),
          AppGap.h16,
          Text(
            T.pronunReadAloud.tr,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          AppGap.h12,
          Text(
            exercise.text,
            style: AppTypography.headlineMedium.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),
          if (exercise.phonetic != null) ...[
            AppGap.h8,
            Text(
              '/${exercise.phonetic}/',
              style: AppTypography.body.copyWith(
                color: AppColors.tertiary,
                fontSize: 16,
              ),
            ),
          ],
          if (exercise.meaning != null) ...[
            AppGap.h8,
            Text(
              exercise.meaning!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: recording ? AppColors.danger : AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: (recording ? AppColors.danger : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: recording ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            recording ? Icons.stop : Icons.mic,
            color: AppColors.onPrimaryFixed,
            size: 36,
          ),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: ctrl.isAssessing.value ? null : ctrl.assessRecording,
        icon: const Icon(Icons.analytics_outlined),
        label: Text(T.pronunAnalysis.tr),
      ),
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
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.pronunciationResult),
        icon: const Icon(Icons.visibility_outlined),
        label: Text(T.actionViewDetail.tr),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
        ),
      ),
    );
  }
}
