import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// Dải nút "Học phần bổ trợ" — các mục không thuộc 4 kỹ năng chính
/// (Từ vựng / Ngữ pháp / Flashcard / Kiểm tra).
class HomeSupplementaryActions extends GetView<HomeController> {
  const HomeSupplementaryActions({super.key});

  static const _actions = <_SuppAction>[
    _SuppAction('vocabulary', 'Từ vựng', Icons.style_rounded),
    _SuppAction('grammar', 'Ngữ pháp', Icons.menu_book_rounded),
    _SuppAction('flashcard', 'Flashcard', Icons.layers_rounded),
    _SuppAction('test', 'Kiểm tra', Icons.fact_check_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Học phần bổ trợ',
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
              return _SuppActionTile(
                action: action,
                onTap: () => controller.openSupplementaryAction(action.key),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SuppAction {
  const _SuppAction(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

class _SuppActionTile extends StatelessWidget {
  const _SuppActionTile({required this.action, required this.onTap});

  final _SuppAction action;
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
        'test' => AppColors.success,
        _ => AppColors.primary,
      };
}
