import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/progress/models/daily_goal.dart';
import 'package:englishme/modules/progress/views/widgets/daily_goal_sheet.dart';
import 'package:englishme/theme/app_theme.dart';

class SettingsSection extends GetView<ProfileController> {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings_rounded, color: AppColors.tertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Cài đặt',
              style: AppTypography.headlineMedium.copyWith(fontSize: 16),
            ),
          ],
        ),
        AppGap.h12,
        _SectionCard(
          children: [
            _ThemeTile(),
            _Divider(),
            _SoundTile(),
            _Divider(),
            _DailyGoalTile(),
            _Divider(),
            _SettingsTile(
              icon: Icons.assignment_rounded,
              iconColor: AppColors.primary,
              title: 'Làm lại Placement Test',
              subtitle: 'Kiểm tra lại trình độ CEFR của bạn',
              onTap: controller.goToPlacementTest,
            ),
          ],
        ),
        AppGap.h12,
        _SectionCard(
          children: [
            _SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: AppColors.danger,
              title: 'Đăng xuất',
              titleColor: AppColors.danger,
              onTap: controller.signOut,
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.outlineVariant,
      indent: 56,
    );
  }
}

class _ThemeTile extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.palette_rounded,
              color: AppColors.tertiary,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giao diện',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chọn chế độ sáng hoặc tối',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final mode = controller.themeMode;
            return _ThemeToggle(
              current: mode,
              onChanged: controller.setThemeMode,
            );
          }),
        ],
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sound = SoundService.to;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.volume_up_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Âm thanh hiệu ứng',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tiếng khi trả lời đúng/sai, hoàn thành bài',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch.adaptive(
              value: sound.enabled.value,
              activeColor: AppColors.primary,
              onChanged: (v) {
                sound.setEnabled(v);
                // Phát thử 1 tiếng ngắn khi bật để user nghe ngay.
                if (v) sound.play(AppSound.correct);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalTile extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final goal = controller.dailyGoal.value;
      final target = goal?.targetXp;
      final subtitle = target == null
          ? 'Đặt số XP cần đạt mỗi ngày'
          : '${DailyGoal.labelFor(target)} · $target XP mỗi ngày';
      return _SettingsTile(
        icon: Icons.flag_rounded,
        iconColor: AppColors.tertiary,
        title: 'Mục tiêu XP mỗi ngày',
        subtitle: subtitle,
        onTap: () => _openSheet(context),
      );
    });
  }

  void _openSheet(BuildContext context) {
    final goal = controller.dailyGoal.value;
    if (goal == null) {
      // Chưa tải xong → thử tải lại, tránh mở sheet rỗng.
      controller.loadDailyGoal();
      return;
    }
    DailyGoalSheet.show(
      context,
      goal: goal,
      onSelect: controller.setDailyGoal,
      isSaving: controller.savingGoal,
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.current, required this.onChanged});
  final ThemeMode current;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            icon: Icons.wb_sunny_rounded,
            selected: current == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            selected: current == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
          _ThemeOption(
            icon: Icons.nights_stay_rounded,
            selected: current == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? AppColors.onPrimaryFixed : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.headlineMedium.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (titleColor == null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
