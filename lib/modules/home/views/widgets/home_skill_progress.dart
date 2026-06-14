import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

/// H3 — đưa per-skill XP (vocab/grammar/phát âm) lên Home dưới dạng mini-bar.
/// Highlight kỹ năng yếu nhất của user bằng màu cảnh báo + nhãn "Cần luyện thêm",
/// để cá nhân hóa "lộ" ra ngay trang chủ thay vì giấu trong tab Tiến độ.
class HomeSkillProgress extends GetView<HomeController> {
  const HomeSkillProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.skills;
      // Chưa có dữ liệu kỹ năng (user mới) -> ẩn hẳn, không làm rối Home.
      if (s == null || !controller.hasSkillData) return const SizedBox.shrink();

      final weakest = controller.weakestSkillKey;

      final bars = <Widget>[
        _SkillBar(
          label: 'Từ vựng',
          icon: Icons.menu_book_rounded,
          value: s.vocabulary,
          isWeak: weakest == 'vocabulary',
        ),
        AppGap.h12,
        _SkillBar(
          label: 'Ngữ pháp',
          icon: Icons.rule_rounded,
          value: s.grammar,
          isWeak: weakest == 'grammar',
        ),
        AppGap.h12,
        _SkillBar(
          label: 'Đọc',
          icon: Icons.article_rounded,
          value: s.reading,
          isWeak: weakest == 'reading',
        ),
        AppGap.h12,
        _SkillBar(
          label: 'Phát âm',
          icon: Icons.record_voice_over_rounded,
          value: s.pronunciation,
          isWeak: weakest == 'pronunciation',
        ),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: InkWell(
            onTap: controller.onOpenWeakSkills,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_rounded,
                          color: AppColors.primary, size: 20),
                      AppGap.w8,
                      Expanded(
                        child: Text(
                          'Kỹ năng của bạn',
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...bars,
                  if (controller.weakestSkillLabel.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _WeakHint(
                      label: controller.weakestSkillLabel,
                      onTap: controller.onPracticeWeakestSkill,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({
    required this.label,
    required this.icon,
    required this.value,
    required this.isWeak,
  });

  final String label;
  final IconData icon;
  final double value; // 0..1
  final bool isWeak;

  @override
  Widget build(BuildContext context) {
    final Color accent = isWeak ? AppColors.tertiary : AppColors.primary;
    final pct = (value.clamp(0.0, 1.0) * 100).round();

    return Row(
      children: [
        Icon(icon, size: 18, color: accent),
        AppGap.w12,
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
        AppGap.w8,
        SizedBox(
          width: 34,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

/// Gợi ý nổi bật cho kỹ năng yếu nhất — cá nhân hóa "lộ" ra.
class _WeakHint extends StatelessWidget {
  const _WeakHint({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.tertiary;
    return Material(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 18, color: accent),
              AppGap.w8,
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'Cần luyện thêm: '),
                      TextSpan(
                        text: label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
