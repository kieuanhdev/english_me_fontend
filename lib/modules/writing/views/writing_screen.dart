import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/writing/controllers/writing_controller.dart';
import 'package:englishme/modules/writing/models/writing_models.dart';
import 'package:englishme/theme/app_theme.dart';

/// Màn luyện Viết theo đề: AI ra đề → viết → AI chấm (điểm + bản sửa + nhận xét).
class WritingScreen extends GetView<WritingController> {
  const WritingScreen({super.key});

  ApiState _mapState(WritingState s) {
    switch (s) {
      case WritingState.loadingPrompt:
      case WritingState.grading:
        return ApiState.loading;
      case WritingState.error:
        return ApiState.error;
      case WritingState.writing:
      case WritingState.result:
        return ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CommonAppBar(title: 'Luyện viết với AI', isTranslate: false),
      body: SafeArea(
        child: Obx(() {
          final s = controller.state.value;
          return ApiStateView(
            state: _mapState(s),
            errorMessage: controller.errorMessage.value.isEmpty
                ? null
                : controller.errorMessage.value,
            onRetry: controller.loadPrompt,
            builder: (_) => s == WritingState.result
                ? _ResultView(controller: controller)
                : _WriteView(controller: controller),
          );
        }),
      ),
    );
  }
}

// ─── Write View ────────────────────────────────────────────────────────────

class _WriteView extends StatefulWidget {
  const _WriteView({required this.controller});
  final WritingController controller;

  @override
  State<_WriteView> createState() => _WriteViewState();
}

class _WriteViewState extends State<_WriteView> {
  final _essay = TextEditingController();
  String _promptId = '';

  int get _wordCount =>
      _essay.text.trim().isEmpty ? 0 : _essay.text.trim().split(RegExp(r'\s+')).length;

  @override
  void dispose() {
    _essay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.controller.prompt.value;
    if (p == null) return const SizedBox.shrink();
    // Đề mới → xóa bài cũ.
    if (p.promptId != _promptId) {
      _promptId = p.promptId;
      _essay.clear();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PromptCard(prompt: p),
                AppGap.h16,
                TextField(
                  controller: _essay,
                  minLines: 6,
                  maxLines: 14,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Viết bài của bạn bằng tiếng Anh ở đây…',
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
                AppGap.h8,
                Text(
                  p.minWords > 0
                      ? '$_wordCount / ${p.minWords} từ (gợi ý)'
                      : '$_wordCount từ',
                  textAlign: TextAlign.right,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: AppButton(
              label: 'Nộp bài',
              isTranslate: false,
              gradient: true,
              radius: AppRadius.pill,
              onPressed: _essay.text.trim().isEmpty
                  ? null
                  : () => widget.controller.submit(_essay.text),
              trailing: const Icon(Icons.send_rounded, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.prompt});
  final WritingPrompt prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prompt.title,
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (prompt.level.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    prompt.level,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          AppGap.h10,
          Text(
            prompt.prompt,
            style: AppTypography.bodyLarge.copyWith(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Result View ───────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});
  final WritingController controller;

  @override
  Widget build(BuildContext context) {
    final g = controller.grade.value;
    if (g == null) return const SizedBox.shrink();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScoreHeader(score: g.score, xp: g.xpEarned),
                if (g.summary.isNotEmpty) ...[
                  AppGap.h16,
                  Text(g.summary,
                      style: AppTypography.bodyLarge
                          .copyWith(fontSize: 14, height: 1.5)),
                ],
                if (g.correctedEssay.isNotEmpty) ...[
                  AppGap.h20,
                  _Section(
                    title: 'Bản viết đã sửa',
                    icon: Icons.auto_fix_high_rounded,
                    color: AppColors.success,
                    child: Text(
                      g.correctedEssay,
                      style: AppTypography.bodyLarge
                          .copyWith(fontSize: 14, height: 1.6),
                    ),
                  ),
                ],
                if (g.strengths.isNotEmpty)
                  _BulletSection(
                    title: 'Điểm mạnh',
                    icon: Icons.thumb_up_alt_rounded,
                    color: AppColors.success,
                    items: g.strengths,
                  ),
                if (g.improvements.isNotEmpty)
                  _BulletSection(
                    title: 'Cần cải thiện',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.skillVocabulary,
                    items: g.improvements,
                  ),
                if (g.vocabSuggestions.isNotEmpty)
                  _BulletSection(
                    title: 'Từ vựng nên học',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.skillGrammar,
                    items: g.vocabSuggestions,
                  ),
                if (g.encouragement.isNotEmpty) ...[
                  AppGap.h16,
                  Text(
                    g.encouragement,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Đóng',
                    isTranslate: false,
                    variant: AppButtonVariant.secondary,
                    radius: AppRadius.pill,
                    onPressed: () => Get.back<void>(),
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: AppButton(
                    label: 'Bài khác',
                    isTranslate: false,
                    gradient: true,
                    radius: AppRadius.pill,
                    onPressed: controller.nextPrompt,
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

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.score, required this.xp});
  final int score;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.success
        : (score >= 50 ? AppColors.skillVocabulary : AppColors.danger);
    return Column(
      children: [
        Text(
          '$score',
          style: AppTypography.displayLarge.copyWith(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          'điểm',
          style: AppTypography.labelSmall
              .copyWith(fontSize: 12, color: AppColors.textSecondary),
        ),
        if (xp > 0) ...[
          AppGap.h8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '+$xp XP',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
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
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
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

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      icon: icon,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: color),
                      ),
                      AppGap.w8,
                      Expanded(
                        child: Text(
                          t,
                          style: AppTypography.bodyLarge
                              .copyWith(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
