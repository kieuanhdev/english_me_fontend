import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/test/controllers/test_controller.dart';
import 'package:englishme/modules/test/models/test_model.dart';
import 'package:englishme/theme/app_theme.dart';

class TestHomeScreen extends GetView<TestController> {
  const TestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppMainAppBar(
                      title: 'Kiểm tra',
                      horizontalPadding: 0,
                    ),
                    AppGap.h6,
                    Text(
                      'Kiểm tra kiến thức của bạn theo chủ đề và cấp độ',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    AppGap.h24,
                    const _SectionLabel(label: 'Chọn chủ đề'),
                    AppGap.h12,
                    _TopicSelector(controller: controller),
                    AppGap.h24,
                    const _SectionLabel(label: 'Chọn cấp độ CEFR'),
                    AppGap.h12,
                    _LevelSelector(controller: controller),
                    AppGap.h28,
                    const _TestInfoCard(),
                    AppGap.h20,
                    _HistorySection(controller: controller),
                  ],
                ),
              ),
            ),
            _StartButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.headlineMedium.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Topic Selector ───────────────────────────────────────────────────────────

class _TopicSelector extends StatelessWidget {
  const _TopicSelector({required this.controller});
  final TestController controller;

  static final _topics = [
    (TestTopic.grammar, Icons.menu_book_rounded, AppColors.skillGrammar),
    (TestTopic.vocabulary, Icons.style_rounded, AppColors.skillVocabulary),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: _topics.asMap().entries.map((entry) {
          final index = entry.key;
          final (topic, icon, color) = entry.value;
          final isSelected = controller.selectedTopic.value == topic;
          final isLast = index == _topics.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 10),
              child: GestureDetector(
                onTap: () => controller.selectTopic(topic),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.12)
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected ? color : AppColors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? color : AppColors.iconMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        topic.label,
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Level Selector ───────────────────────────────────────────────────────────

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({required this.controller});
  final TestController controller;

  static const _levels = TestLevel.values;

  static Color _levelColor(TestLevel l) => switch (l) {
    TestLevel.a1 => const Color(0xFF4CAF50),
    TestLevel.a2 => const Color(0xFF8BC34A),
    TestLevel.b1 => const Color(0xFFFFB74D),
    TestLevel.b2 => const Color(0xFFFF7043),
    TestLevel.c1 => const Color(0xFFE53935),
    TestLevel.c2 => const Color(0xFF9C27B0),
  };

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _levels.map((level) {
          final isSelected = controller.selectedLevel.value == level;
          final color = _levelColor(level);
          return GestureDetector(
            onTap: () => controller.selectLevel(level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.12)
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? color : AppColors.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                level.label,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Test Info Card ───────────────────────────────────────────────────────────

class _TestInfoCard extends StatelessWidget {
  const _TestInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Thông tin bài kiểm tra',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppGap.h12,
          const Row(
            children: [
              _InfoChip(icon: Icons.quiz_rounded, label: '10 câu hỏi'),
              AppGap.w12,
              _InfoChip(icon: Icons.timer_outlined, label: '15 phút'),
              AppGap.w12,
              _InfoChip(
                icon: Icons.check_circle_outline_rounded,
                label: 'Trắc nghiệm',
              ),
            ],
          ),
          AppGap.h10,
          Text(
            'Chọn đáp án đúng cho mỗi câu hỏi. Bài kiểm tra tự động nộp khi hết giờ.',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 12,
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ─── History Section ──────────────────────────────────────────────────────────

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});
  final TestController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isHistoryLoading.value) return const SizedBox.shrink();
      if (controller.history.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Lịch sử kiểm tra'),
          AppGap.h12,
          ...controller.history
              .take(3)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HistoryTile(entry: entry),
                ),
              ),
        ],
      );
    });
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});
  final TestHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final pct = entry.accuracy;
    final color = pct >= 0.7
        ? AppColors.success
        : (pct >= 0.5 ? AppColors.skillVocabulary : AppColors.danger);
    final score = (pct * 100).round();
    final daysAgo = DateTime.now().difference(entry.completedAt).inDays;
    final timeText = daysAgo == 0 ? 'Hôm nay' : '$daysAgo ngày trước';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$score%',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.topic.label} · ${entry.level.label}',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.correct}/${entry.total} câu đúng · $timeText',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Start Button ─────────────────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  const _StartButton({required this.controller});
  final TestController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Obx(() {
          final canStart =
              controller.selectedTopic.value != null &&
              controller.selectedLevel.value != null;
          return AppButton(
            label: 'Bắt đầu kiểm tra',
            isTranslate: false,
            onPressed: canStart ? controller.startTest : null,
            leading: const Icon(Icons.play_arrow_rounded, size: 20),
            textStyle: AppTypography.headlineMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimaryFixed,
            ),
          );
        }),
      ),
    );
  }
}
