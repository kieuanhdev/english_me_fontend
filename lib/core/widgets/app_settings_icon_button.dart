import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Mở màn Profile / Cài đặt (shell tab 4).
class AppSettingsIconButton extends StatelessWidget {
  const AppSettingsIconButton({super.key, this.size = 40, this.iconSize = 20});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ShellController.goToTab(4),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.settings_outlined,
          size: iconSize,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
