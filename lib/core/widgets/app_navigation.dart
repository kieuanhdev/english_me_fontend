import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    required this.onPressed,
    this.size = 32,
    super.key,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0xFFCBD5DD), offset: Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
      ),
    );
  }
}

class AppBackWithProgress extends StatelessWidget {
  const AppBackWithProgress({
    required this.onBack,
    required this.progress,
    this.backButtonSize = 32,
    super.key,
  });

  final VoidCallback onBack;
  final double progress;
  final double backButtonSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(onPressed: onBack, size: backButtonSize),
        AppGap.w12,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFD3DAE2),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
