import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

class WelcomeColors {
  static const Color bg = AppColors.surface;
  static const Color surface = AppColors.surfaceContainerLowest;
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryContainer;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color text = AppColors.onSurface;
  static const Color textMuted = AppColors.textSecondary;
  static const Color border = AppColors.outlineVariant;
}

class WelcomeTypography {
  static TextStyle get brand => AppTypography.brand;
  static TextStyle get titleMain => AppTypography.displayLarge;
  static TextStyle get titleAccent => AppTypography.displayAccent;
  static TextStyle get body => AppTypography.bodyLarge;
  static TextStyle get buttonLabel => AppTypography.labelMedium;
  static TextStyle get language => AppTypography.labelMedium;
}
