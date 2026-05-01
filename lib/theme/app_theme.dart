import 'package:flutter/material.dart';

class AppColors {
  // 1. Core Authority Colors
  static const Color primary = Color(0xFF24389C); // Deep Indigo
  static const Color primaryContainer = Color(
    0xFF3F51B5,
  ); // Indigo cho Gradient
  static const Color tertiary = Color(0xFFE67E22); // Burnished Orange (Accent)
  static const Color tertiaryFixedDim = Color(
    0xFFF39C12,
  ); // Cam nhạt cho trạng thái đúng

  // 2. Surface Hierarchy (Tactile layering)
  static const Color surface = Color(
    0xFFF9F9F9,
  ); // Base Layer (Global background)
  static const Color surfaceContainerLow = Color(
    0xFFF3F3F4,
  ); // Content Areas (Nhóm bài học)
  static const Color surfaceContainerLowest = Color(
    0xFFFFFFFF,
  ); // Interactive Units (Cards)
  static const Color surfaceContainerHigh = Color(
    0xFFEBEBEB,
  ); // Inputs & Secondary buttons

  // 3. Text & Line-less Borders
  static const Color onSurface = Color(0xFF1A1C1C); // Thay cho Pure Black
  static const Color textSecondary = Color(0xFF5B6B7C);
  static const Color outlineVariant = Color(
    0x261A1C1C,
  ); // Ghost Border (15% opacity)

  static const Color secondaryContainer = Color(0xFFD7DEE6); // Progress Track

  // 4. Semantic: Danger
  static const Color danger = Color(0xFFE53935);
  static const Color dangerDark = Color(0xFFB71C1C);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color dangerPanel = Color(0xFFFFF0F0);

  // 5. Semantic: Success
  static const Color success = Color(0xFF43A047);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFEDF7EE);
  static const Color successPanel = Color(0xFFF1FBF2);
  static const Color successShadow = Color(0xFF2E7D32);

  // 6. Skill Colors
  static const Color skillVocabulary = Color(0xFFF4B400);
  static const Color skillGrammar = Color(0xFF1976D2);
  static const Color skillListening = Color(0xFFE53935);

  // 7. Utility
  static const Color primarySoft = Color(0x1424389C);
  static const Color primarySoftSelected = Color(0x2024389C);
  static const Color neutralShadow = Color(0xFFCBD5DD);
  static const Color iconMuted = Color(0xFF9EA8B3);

  // Signature Gradient cho Primary CTA
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTypography {
  // Headlines: Be Vietnam Pro (Modern Authority)
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Word of the Day: Editorial Intent
  static TextStyle get titleLargeTertiary => const TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.tertiary,
  );

  // Body: Plus Jakarta Sans (Friendly apertures)
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.onSurface, // English definitions
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, // Vietnamese translations
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.primary,
  );

  // Alias for semantic naming used in widgets
  static TextStyle get body => bodyLarge;
  static TextStyle get caption => labelMedium;
  static TextStyle get button => labelMedium;

  // Brand wordmark style
  static TextStyle get brand => const TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.3,
  );

  // Accent display (orange)
  static TextStyle get displayAccent => const TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.tertiary,
    letterSpacing: -0.5,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
    );

    return base.copyWith(
      // Loại bỏ Divider hoàn toàn theo luật No-Line
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        space: 32,
      ),

      // AppBar trong suốt để text "chảy" mượt mà khi scroll
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),

      // ElevatedButton mặc định (Vẫn cần bọc Gradient thủ công ở Widget)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary, // Fallback nếu không có gradient
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // xl roundedness
          ),
          textStyle: AppTypography.labelMedium.copyWith(color: Colors.white),
        ),
      ),

      // Input Style theo quy tắc Modern Lexicon
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // lg roundedness
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0x3324389C), // Ghost Border 20%
            width: 2,
          ),
        ),
      ),

      // Card style: No borders, tonal lift
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
