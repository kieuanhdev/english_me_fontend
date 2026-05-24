import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_topic_controller.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_level.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabWordListScreen extends GetView<VocabTopicController> {
  const VocabWordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Obx(() {
                ApiState mapState() {
                  switch (controller.wordsState.value) {
                    case VocabLoadState.idle:
                    case VocabLoadState.loading:
                      return ApiState.loading;
                    case VocabLoadState.error:
                      return ApiState.error;
                    case VocabLoadState.loaded:
                      return controller.words.isEmpty ? ApiState.empty : ApiState.success;
                  }
                }

                return ApiStateView(
                  state: mapState(),
                  errorMessage: 'Không tải được từ vựng',
                  emptyMessage: 'Chủ đề chưa có từ vựng',
                  onRetry: () {
                    final topic = controller.currentTopic.value;
                    if (topic != null) controller.openTopic(topic);
                  },
                  builder: (_) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: controller.words.length,
                    separatorBuilder: (_, __) => AppGap.h12,
                    itemBuilder: (_, i) => _VocabCard(word: controller.words[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SpellingButton(),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends GetView<VocabTopicController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.onSurface),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Obx(() {
              final topic = controller.currentTopic.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic?.nameEn ?? '',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    topic != null ? '${topic.wordCount} từ • ${topic.level.label}' : '',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            final saved = controller.savedWords.length;
            return saved > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$saved',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// ─── Vocab Card (flip) ────────────────────────────────────────────────────────

class _VocabCard extends GetView<VocabTopicController> {
  const _VocabCard({required this.word});
  final VocabWord word;

  Color _levelColor(VocabLevel level) => switch (level) {
        VocabLevel.a1 => const Color(0xFF4CAF50),
        VocabLevel.a2 => const Color(0xFF8BC34A),
        VocabLevel.b1 => const Color(0xFF2196F3),
        VocabLevel.b2 => const Color(0xFF9C27B0),
        VocabLevel.c1 => const Color(0xFFFF9800),
        VocabLevel.c2 => const Color(0xFFF44336),
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final flipped = controller.isFlipped(word.id);
      final saved = controller.isSaved(word.id);
      final levelColor = _levelColor(word.level);

      return GestureDetector(
        onTap: () => controller.toggleCard(word.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: flipped ? AppColors.primarySoft : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: flipped ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant,
              width: flipped ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: flipped
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.shadowSoft,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              word.word,
                              style: AppTypography.labelMedium.copyWith(
                                color: flipped ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                            AppGap.w8,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: levelColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                word.level.label,
                                style: AppTypography.labelXSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: levelColor,
                                ),
                              ),
                            ),
                            if (word.partOfSpeech.isNotEmpty) ...[
                              AppGap.w8,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  word.partOfSpeech,
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.ipa,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.toggleSave(word.id),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        key: ValueKey(saved),
                        size: 22,
                        color: saved ? AppColors.primary : AppColors.iconMuted,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: flipped ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_rounded, size: 14, color: AppColors.iconMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Nhấn để xem nghĩa',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.flagRedVN.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Center(child: Text('🇻🇳', style: TextStyle(fontSize: 14))),
                        ),
                        AppGap.w10,
                        Expanded(
                          child: Text(
                            word.definitionVi,
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.flagBlueUK.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Center(child: Text('🇬🇧', style: TextStyle(fontSize: 14))),
                        ),
                        AppGap.w10,
                        Expanded(
                          child: Text(
                            word.definitionEn,
                            style: AppTypography.bodyLarge.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (word.exampleSentence.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_quote_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Ví dụ',
                                  style: AppTypography.labelXSmall.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              word.exampleSentence,
                              style: AppTypography.bodyLarge.copyWith(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (word.exampleTranslation.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                word.exampleTranslation,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Spelling Button ──────────────────────────────────────────────────────────

class _SpellingButton extends GetView<VocabTopicController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Obx(() {
          final loaded = controller.wordsState.value == VocabLoadState.loaded;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: loaded ? controller.startSpelling : null,
              icon: const Icon(Icons.spellcheck_rounded, size: 20),
              label: Text(
                'Luyện đánh vần',
                style: AppTypography.labelMedium.copyWith(fontSize: 15),
              ),
            ),
          );
        }),
      ),
    );
  }
}
