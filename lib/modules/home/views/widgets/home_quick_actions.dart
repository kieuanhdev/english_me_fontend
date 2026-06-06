import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// Dải nút truy cập nhanh tới các học phần bổ trợ.
class HomeQuickActions extends GetView<HomeController> {
  const HomeQuickActions({super.key});

  static const _actions = <_QuickAction>[
    _QuickAction('vocabulary', 'Từ vựng', Icons.style_rounded),
    _QuickAction('grammar', 'Ngữ pháp', Icons.menu_book_rounded),
    _QuickAction('flashcard', 'Flashcard', Icons.layers_rounded),
    _QuickAction('pronunciation', 'Phát âm', Icons.record_voice_over_rounded),
    _QuickAction('test', 'Kiểm tra', Icons.fact_check_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Luyện tập nhanh',
            style: AppTypography.displayLarge.copyWith(fontSize: 17),
          ),
        ),
        AppGap.h12,
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _actions.length,
            separatorBuilder: (_, __) => AppGap.w12,
            itemBuilder: (_, index) {
              final action = _actions[index];
              return _QuickActionTile(
                action: action,
                onTap: () => controller.openQuickAction(action.key),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(action.key);
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(action.icon, color: color, size: 21),
              ),
              AppGap.h8,
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(String key) => switch (key) {
        'vocabulary' => AppColors.skillVocabulary,
        'grammar' => AppColors.skillGrammar,
        'flashcard' => AppColors.tertiary,
        'pronunciation' => AppColors.skillListening,
        'test' => AppColors.success,
        _ => AppColors.primary,
      };
}
