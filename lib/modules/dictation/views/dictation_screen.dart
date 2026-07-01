import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/dictation/controllers/dictation_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// Màn luyện Nghe - chép chính tả (dictation). TTS đọc câu, user gõ lại,
/// chấm so khớp chuẩn hóa, highlight từng từ. Kết quả + XP ở cuối.
class DictationScreen extends GetView<DictationController> {
  const DictationScreen({super.key});

  ApiState _mapState(DictationState s) {
    switch (s) {
      case DictationState.idle:
      case DictationState.loading:
      case DictationState.submitting:
        return ApiState.loading;
      case DictationState.error:
        return ApiState.error;
      case DictationState.playing:
        return controller.current == null ? ApiState.empty : ApiState.success;
      case DictationState.finished:
        return ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          if (controller.state.value == DictationState.finished) {
            return _ResultView(controller: controller);
          }
          return ApiStateView(
            state: _mapState(controller.state.value),
            errorMessage: controller.errorMessage.value.isEmpty
                ? null
                : controller.errorMessage.value,
            emptyMessage: 'Chưa có câu luyện nghe.',
            onRetry: controller.retry,
            builder: (_) => _PlayView(controller: controller),
          );
        }),
      ),
    );
  }
}

// ─── Play View ──────────────────────────────────────────────────────────────

class _PlayView extends StatefulWidget {
  const _PlayView({required this.controller});
  final DictationController controller;

  @override
  State<_PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<_PlayView> {
  final _input = TextEditingController();
  int _lastIndex = -1;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Obx(() {
      // Đổi câu → xóa ô nhập + tự phát câu mới.
      final idx = c.currentIndex.value;
      if (idx != _lastIndex) {
        _lastIndex = idx;
        _input.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) => c.playCurrent());
      }
      final revealed = c.isRevealed.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AppBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Progress(
              current: c.currentIndex.value + 1,
              total: c.total,
              correctCount: c.correctCount,
            ),
          ),
          AppGap.h24,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlayButton(onTap: c.playCurrent),
                  if (c.current?.hint != null &&
                      c.current!.hint!.trim().isNotEmpty) ...[
                    AppGap.h12,
                    _HintChip(hint: c.current!.hint!.trim()),
                  ],
                  AppGap.h20,
                  TextField(
                    controller: _input,
                    enabled: !revealed,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Gõ lại câu bạn nghe được…',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                    ),
                  ),
                  if (revealed) ...[
                    AppGap.h18,
                    _AnswerReveal(
                      correct: c.lastCorrect.value,
                      diff: c.diff.toList(),
                    ),
                  ],
                  AppGap.h20,
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: revealed
                  ? AppButton(
                      label: c.isLast ? 'Xem kết quả' : 'Câu tiếp theo',
                      isTranslate: false,
                      gradient: true,
                      radius: AppRadius.pill,
                      onPressed: c.next,
                      trailing: Icon(
                        c.isLast
                            ? Icons.emoji_events_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    )
                  : AppButton(
                      label: 'Kiểm tra',
                      isTranslate: false,
                      gradient: true,
                      radius: AppRadius.pill,
                      onPressed: () => c.check(_input.text),
                      trailing: const Icon(Icons.check_rounded, size: 18),
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          AppCloseButton(
            onPressed: () {
              Get.find<TtsService>().stop();
              Get.back<void>();
            },
          ),
          AppGap.w8,
          Text(
            'Nghe chép chính tả',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
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
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: '/$total',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.iconMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$correctCount đúng',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        AppGap.h8,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: AppColors.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration:
                        BoxDecoration(gradient: AppColors.primaryGradient),
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.volume_up_rounded, size: 40, color: AppColors.primary),
            AppGap.h8,
            Text(
              'Nhấn để nghe lại',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lightbulb_outline_rounded,
            size: 14, color: AppColors.iconMuted),
        const SizedBox(width: 6),
        Text(
          'Gợi ý: $hint',
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AnswerReveal extends StatelessWidget {
  const _AnswerReveal({required this.correct, required this.diff});
  final bool correct;
  final List<DictationWordDiff> diff;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? AppColors.successPanel : AppColors.dangerPanel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 16,
                color: correct ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 6),
              Text(
                correct ? 'Chính xác!' : 'Đáp án đúng',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: correct ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
          AppGap.h10,
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: diff
                .map((d) => Text(
                      d.word,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: d.correct ? AppColors.onSurface : AppColors.danger,
                        decoration:
                            d.correct ? null : TextDecoration.underline,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Result View ──────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});
  final DictationController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.total;
    final correct = controller.correctCount;
    final xp = controller.xpEarned;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.emoji_events_rounded, size: 72, color: AppColors.primary),
          AppGap.h16,
          Text(
            'Hoàn thành!',
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge.copyWith(fontSize: 24),
          ),
          AppGap.h12,
          Text(
            'Đúng $correct/$total câu',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 18,
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (xp > 0) ...[
            AppGap.h8,
            Text(
              '+$xp XP',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          AppGap.h32,
          AppButton(
            label: 'Luyện tiếp',
            isTranslate: false,
            gradient: true,
            radius: AppRadius.pill,
            onPressed: controller.retry,
          ),
          AppGap.h12,
          AppButton(
            label: 'Đóng',
            isTranslate: false,
            variant: AppButtonVariant.secondary,
            radius: AppRadius.pill,
            onPressed: () => Get.back<void>(),
          ),
        ],
      ),
    );
  }
}
