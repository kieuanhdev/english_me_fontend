import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/core/widgets/confetti_overlay.dart';
import 'package:englishme/modules/learn/controllers/checkpoint_controller.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/theme/app_theme.dart';

/// Level Checkpoint Test — bài kiểm tra cuối cấp để lên cấp CEFR.
class CheckpointScreen extends GetView<CheckpointController> {
  const CheckpointScreen({super.key});

  ApiState _stateOf() {
    if (controller.loading.value) return ApiState.loading;
    if (controller.error.value.isNotEmpty) return ApiState.error;
    return controller.state.value == null ? ApiState.empty : ApiState.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(() {
            return ApiStateView(
              state: _stateOf(),
              errorMessage: 'Không tải được bài kiểm tra.',
              emptyMessage: 'Cấp độ này chưa có bài kiểm tra.',
              onRetry: controller.load,
              builder: (_) {
                if (controller.result.value != null) return _result(context);
                final s = controller.state.value!;
                if (!s.unlocked) return _locked(s);
                if (s.questions.isEmpty) return _empty();
                return _quiz(context, s);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _header(String title) => Row(
        children: [
          AppBackButton(onPressed: Get.back),
          AppGap.w12,
          Expanded(
            child: Text(title,
                style: AppTypography.displayLarge
                    .copyWith(fontSize: 18, color: AppColors.primary)),
          ),
        ],
      );

  // ── Khoá (chưa đủ độ phủ Unit) ──
  Widget _locked(CheckpointState s) {
    final pct = (s.requiredUnitProgress * 100).round();
    final cur = (s.unitProgress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Kiểm tra cuối cấp ${s.level}'),
        const Spacer(),
        Center(
          child: Column(
            children: [
              Icon(Icons.lock_outline, size: 64, color: AppColors.textSecondary),
              AppGap.h16,
              Text('Chưa mở khoá',
                  style: AppTypography.headlineMedium.copyWith(color: AppColors.primary)),
              AppGap.h8,
              Text(
                'Hoàn thành ít nhất $pct% số Unit của cấp ${s.level} để mở bài kiểm tra.\n'
                'Hiện tại: $cur%.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _empty() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('Kiểm tra cuối cấp'),
          const Spacer(),
          const Center(child: Text('Chưa có câu hỏi cho bài kiểm tra này.')),
          const Spacer(),
        ],
      );

  // ── Làm bài ──
  Widget _quiz(BuildContext context, CheckpointState s) {
    final a = controller.current;
    if (a == null) return _empty();
    final total = s.questions.length;
    final idx = controller.index.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('${s.title} · Câu ${idx + 1}/$total'),
        AppGap.h8,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : (idx + 1) / total,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHigh,
          ),
        ),
        AppGap.h16,
        Text(a.question,
            style: AppTypography.headlineMedium
                .copyWith(color: AppColors.primary, fontSize: 17)),
        AppGap.h16,
        Expanded(child: SingleChildScrollView(child: _input(a))),
        AppButton(
          label: idx < total - 1 ? 'Câu tiếp' : 'Nộp bài',
          isTranslate: false,
          onPressed: controller.canSubmitCurrent && !controller.submitting.value
              ? controller.next
              : null,
        ),
      ],
    );
  }

  Widget _input(CurriculumActivity a) {
    // mcq | listening_choice
    if (!a.isTextInput && !a.isOrdering) {
      return Column(
        children: a.options
            .map((o) => Obx(() {
                  final sel = controller.selected.value == o.id;
                  return Card(
                    color: sel ? AppColors.primaryContainer : AppColors.surface,
                    child: ListTile(
                      title: Text(o.text),
                      onTap: () => controller.select(o.id),
                    ),
                  );
                }))
            .toList(),
      );
    }
    // fill_blank | translation | error_correction
    if (a.isTextInput) {
      return TextField(
        onChanged: controller.type,
        decoration: const InputDecoration(
          hintText: 'Nhập câu trả lời...',
          border: OutlineInputBorder(),
        ),
      );
    }
    // sentence_ordering
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < a.tokens.length; i++)
                  ChoiceChip(
                    label: Text(a.tokens[i]),
                    selected: controller.order.contains(i),
                    onSelected: (_) => controller.toggleOrder(i),
                  ),
              ],
            )),
        AppGap.h8,
        Obx(() => Text(
              'Thứ tự: ${controller.order.map((i) => a.tokens[i]).join(' ')}',
              style: AppTypography.bodyMedium,
            )),
        AppButton(
          label: 'Xoá',
          isTranslate: false,
          variant: AppButtonVariant.text,
          expand: false,
          onPressed: controller.resetOrder,
        ),
      ],
    );
  }

  // ── Kết quả ──
  Widget _result(BuildContext context) {
    final r = controller.result.value!;
    // Lên cấp → bắn confetti phủ màn 1 lần (sau frame để Overlay sẵn sàng).
    if (r.leveledUp && !controller.levelUpConfettiShown) {
      controller.levelUpConfettiShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) ConfettiOverlay.burst(context);
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Kết quả'),
        const Spacer(),
        Center(
          child: Column(
            children: [
              Icon(r.passed ? Icons.emoji_events : Icons.refresh,
                  size: 72,
                  color: r.passed ? AppColors.tertiary : AppColors.textSecondary),
              AppGap.h16,
              Text('${r.score}%',
                  style: AppTypography.displayLarge
                      .copyWith(fontSize: 40, color: AppColors.primary)),
              AppGap.h8,
              Text(
                r.passed ? 'ĐẠT (cần ≥ ${r.passScore}%)' : 'CHƯA ĐẠT (cần ≥ ${r.passScore}%)',
                style: AppTypography.headlineMedium.copyWith(
                    color: r.passed ? AppColors.tertiary : AppColors.danger),
              ),
              if (r.leveledUp) ...[
                AppGap.h16,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '🎉 Lên cấp ${r.fromLevel} → ${r.toLevel}!  +${r.xpEarned} XP',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        AppButton(
          label: 'Hoàn tất',
          isTranslate: false,
          onPressed: () => Get.back(result: r.leveledUp),
        ),
      ],
    );
  }
}
