import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

class WelcomeColors {
  static const Color bg = AppColors.bg;
  static const Color surface = AppColors.surface;
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color text = AppColors.text;
  static const Color textMuted = AppColors.textMuted;
  static const Color border = AppColors.border;
}

class WelcomeTypography {
  static TextStyle get brand => AppTypography.brand;
  static TextStyle get titleMain => AppTypography.displayLarge;
  static TextStyle get titleAccent => AppTypography.displayAccent;
  static TextStyle get body => AppTypography.body;
  static TextStyle get buttonLabel => AppTypography.button;
  static TextStyle get language => AppTypography.caption;
}
