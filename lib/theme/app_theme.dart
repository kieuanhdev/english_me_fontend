import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFFF7FAFC); // --ink-50
  static const Color surface = Color(0xFFFFFFFF); // --white
  static const Color primary = Color(0xFF0EA5A4); // --teal-500
  static const Color primaryDark = Color(0xFF086B6B); // --teal-700
  static const Color primarySoft = Color(0xFFE6FAF9); // --teal-50
  static const Color primarySoftSelected = Color(0xFFE2F3F2);
  static const Color text = Color(0xFF0D1B2A); // --ink-900
  static const Color textMuted = Color(0xFF5B6B7C); // --ink-500
  static const Color border = Color(0xFFE4EAF0); // --ink-200

  static const Color neutralShadow = Color(0xFFCBD5DD);
  static const Color progressTrack = Color(0xFFD7DEE6);
  static const Color iconMuted = Color(0xFF7D8EA4);

  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF148A40);
  static const Color successShadow = Color(0xFF17803A);
  static const Color successSoft = Color(0xFFE4F7E9);
  static const Color successPanel = Color(0xFFE4F4E9);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFCE8E8);
  static const Color dangerPanel = Color(0xFFFBE8E8);

  static const Color skillGrammar = Color(0xFF16A7A4);
  static const Color skillVocabulary = Color(0xFFF4B12D);
  static const Color skillListening = Color(0xFFF06191);
}

class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.baloo2(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: AppColors.text,
      );

  static TextStyle get displayAccent => GoogleFonts.baloo2(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: AppColors.primary,
      );

  static TextStyle get brand => GoogleFonts.baloo2(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.2,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textMuted,
      );

  static TextStyle get button => GoogleFonts.baloo2(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
