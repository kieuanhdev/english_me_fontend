import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthFormPanel extends StatelessWidget {
  const AuthFormPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: AppTypography.headlineMedium.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: AppColors.googleBrand,
      ),
    );
  }
}
