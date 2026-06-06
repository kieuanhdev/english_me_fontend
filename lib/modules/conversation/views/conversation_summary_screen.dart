import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/conversation/controllers/conversation_controller.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Màn tổng kết & nhận xét đoạn hội thoại.
class ConversationSummaryScreen extends StatelessWidget {
  const ConversationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConversationController>();
    final s = ctrl.summary.value;

    if (s == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: AppColors.textSecondary),
                AppGap.h16,
                Text(
                  'Không có dữ liệu tổng kết.',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                AppGap.h16,
                AppButton(
                  label: 'Quay lại',
                  isTranslate: false,
                  expand: false,
                  onPressed: Get.back,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(
                title: 'Tổng kết hội thoại',
                showBack: true,
                showSettings: false,
                showNotification: false,
                horizontalPadding: 0,
                onBack: Get.back,
              ),
              AppGap.h20,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ScoreHeader(score: s.overallScore),
                      AppGap.h20,
                      _SummaryCard(text: s.summary),
                      if (s.strengths.isNotEmpty) ...[
                        AppGap.h20,
                        _ListCard(
                          title: 'Điểm tốt',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          items: s.strengths,
                        ),
                      ],
                      if (s.improvements.isNotEmpty) ...[
                        AppGap.h20,
                        _ListCard(
                          title: 'Cần cải thiện',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.danger,
                          items: s.improvements,
                        ),
                      ],
                      if (s.vocabSuggestions.isNotEmpty) ...[
                        AppGap.h20,
                        _ListCard(
                          title: 'Từ vựng nên học',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.tertiary,
                          items: s.vocabSuggestions,
                        ),
                      ],
                      if (s.encouragement.isNotEmpty) ...[
                        AppGap.h20,
                        _EncouragementCard(text: s.encouragement),
                      ],
                      AppGap.h24,
                    ],
                  ),
                ),
              ),
              AppButton(
                label: 'Luyện chủ đề khác',
                isTranslate: false,
                onPressed: ctrl.resetSession,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.score});

  final int score;

  Color _color() {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.tertiary;
    return AppColors.danger;
  }

  String _label() {
    if (score >= 90) return 'Xuất sắc!';
    if (score >= 80) return 'Tốt!';
    if (score >= 60) return 'Khá';
    return 'Cần cố gắng thêm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'Điểm giao tiếp',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          AppGap.h12,
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(_color()),
                ),
                Text(
                  '$score',
                  style: AppTypography.displayLarge
                      .copyWith(fontSize: 28, color: _color()),
                ),
              ],
            ),
          ),
          AppGap.h16,
          Text(
            _label(),
            style: AppTypography.headlineMedium
                .copyWith(fontSize: 22, color: _color()),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.text});

  final String text;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h12,
          Text(text, style: AppTypography.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              AppGap.w8,
              Text(
                title,
                style: AppTypography.body
                    .copyWith(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          AppGap.h12,
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.body.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 22),
          AppGap.w12,
          Expanded(
            child: Text(text, style: AppTypography.body.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
