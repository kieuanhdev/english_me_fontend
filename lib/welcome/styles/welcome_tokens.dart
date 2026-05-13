import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

class WelcomeColors {
  static Color get bg => AppColors.surface;
  static Color get surface => AppColors.surfaceContainerLowest;
  static Color get primary => AppColors.primary;
  static Color get primaryDark => AppColors.primaryContainer;
  static Color get primarySoft => AppColors.primarySoft;
  static Color get text => AppColors.onSurface;
  static Color get textMuted => AppColors.textSecondary;
  static Color get border => AppColors.outlineVariant;
}

class WelcomeTypography {
  static TextStyle get brand => AppTypography.brand;
  static TextStyle get titleMain => AppTypography.displayLarge;
  static TextStyle get titleAccent => AppTypography.displayAccent;
  static TextStyle get body => AppTypography.bodyLarge;
  static TextStyle get buttonLabel => AppTypography.labelMedium;
  static TextStyle get language => AppTypography.labelMedium;
}
