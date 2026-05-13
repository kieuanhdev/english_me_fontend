import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/theme/theme_controller.dart';

@immutable
class AppPaletteColors {
  const AppPaletteColors({
    required this.brightness,
    required this.primary,
    required this.primaryContainer,
    required this.tertiary,
    required this.tertiaryFixedDim,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.surfaceContainerHigh,
    required this.onSurface,
    required this.textSecondary,
    required this.outlineVariant,
    required this.secondaryContainer,
    required this.danger,
    required this.dangerDark,
    required this.dangerSoft,
    required this.dangerPanel,
    required this.success,
    required this.successDark,
    required this.successSoft,
    required this.successPanel,
    required this.successShadow,
    required this.skillVocabulary,
    required this.skillGrammar,
    required this.skillListening,
    required this.primarySoft,
    required this.primarySoftSelected,
    required this.neutralShadow,
    required this.iconMuted,
    required this.brandHue,
    required this.tertiaryBgSoft,
    required this.recommendationMutedBg,
    required this.chipHighlightBg,
  });

  final Brightness brightness;

  final Color primary;
  final Color primaryContainer;
  final Color tertiary;
  final Color tertiaryFixedDim;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color surfaceContainerHigh;
  final Color onSurface;
  final Color textSecondary;
  final Color outlineVariant;
  final Color secondaryContainer;
  final Color danger;
  final Color dangerDark;
  final Color dangerSoft;
  final Color dangerPanel;
  final Color success;
  final Color successDark;
  final Color successSoft;
  final Color successPanel;
  final Color successShadow;
  final Color skillVocabulary;
  final Color skillGrammar;
  final Color skillListening;
  final Color primarySoft;
  final Color primarySoftSelected;
  final Color neutralShadow;
  final Color iconMuted;

  /// Chữ nhãn cho brand trong light vs dark (AppTypography.brand / displayAccent)
  final Color brandHue;
  final Color tertiaryBgSoft;

  /// Nền thẻ gợi ý (home_recommendations) khi không dùng cam
  final Color recommendationMutedBg;

  /// Highlight chọn trong form (vd. create_desk)
  final Color chipHighlightBg;

  Gradient get primaryGradient => LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

const AppPaletteColors kLightPalette = AppPaletteColors(
  brightness: Brightness.light,
  primary: Color(0xFF24389C),
  primaryContainer: Color(0xFF3F51B5),
  tertiary: Color(0xFFE67E22),
  tertiaryFixedDim: Color(0xFFF39C12),
  surface: Color(0xFFF9F9F9),
  surfaceContainerLow: Color(0xFFF3F3F4),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerHigh: Color(0xFFEBEBEB),
  onSurface: Color(0xFF1A1C1C),
  textSecondary: Color(0xFF5B6B7C),
  outlineVariant: Color(0x261A1C1C),
  secondaryContainer: Color(0xFFD7DEE6),
  danger: Color(0xFFE53935),
  dangerDark: Color(0xFFB71C1C),
  dangerSoft: Color(0xFFFDECEC),
  dangerPanel: Color(0xFFFFF0F0),
  success: Color(0xFF43A047),
  successDark: Color(0xFF2E7D32),
  successSoft: Color(0xFFEDF7EE),
  successPanel: Color(0xFFF1FBF2),
  successShadow: Color(0xFF2E7D32),
  skillVocabulary: Color(0xFFF4B400),
  skillGrammar: Color(0xFF1976D2),
  skillListening: Color(0xFFE53935),
  primarySoft: Color(0x1424389C),
  primarySoftSelected: Color(0x2024389C),
  neutralShadow: Color(0xFFCBD5DD),
  iconMuted: Color(0xFF9EA8B3),
  brandHue: Color(0xFF24389C),
  tertiaryBgSoft: Color(0xFFFFF3E0),
  recommendationMutedBg: Color(0xFFF3F3F4),
  chipHighlightBg: Color(0xFFE9EEFF),
);

const AppPaletteColors kDarkPalette = AppPaletteColors(
  brightness: Brightness.dark,
  primary: Color(0xFFAAB4FC),
  primaryContainer: Color(0xFF5F66C9),
  tertiary: Color(0xFFFFB74D),
  tertiaryFixedDim: Color(0xFFFF9800),
  surface: Color(0xFF0F1117),
  surfaceContainerLow: Color(0xFF171A22),
  surfaceContainerLowest: Color(0xFF1E222C),
  surfaceContainerHigh: Color(0xFF2A303E),
  onSurface: Color(0xFFE7EAF0),
  textSecondary: Color(0xFF9AA5B8),
  outlineVariant: Color(0x33FFFFFF),
  secondaryContainer: Color(0xFF384055),
  danger: Color(0xFFFF6B69),
  dangerDark: Color(0xFFFF5252),
  dangerSoft: Color(0xFF3A2225),
  dangerPanel: Color(0xFF2C1A1E),
  success: Color(0xFF66BB6A),
  successDark: Color(0xFF43A047),
  successSoft: Color(0xFF25352A),
  successPanel: Color(0xFF1E2B24),
  successShadow: Color(0xFF2E7D32),
  skillVocabulary: Color(0xFFFFCA28),
  skillGrammar: Color(0xFF64B5F6),
  skillListening: Color(0xFFFF8A80),
  primarySoft: Color(0x30AAB4FC),
  primarySoftSelected: Color(0x44AAB4FC),
  neutralShadow: Color(0x66000000),
  iconMuted: Color(0xFF7F8B99),
  brandHue: Color(0xFFAAB4FC),
  tertiaryBgSoft: Color(0xFF3D2F1F),
  recommendationMutedBg: Color(0xFF171A22),
  chipHighlightBg: Color(0xFF2D3350),
);

class AppColors {
  static AppPaletteColors get _effective {
    if (!Get.isRegistered<ThemeController>()) return kLightPalette;
    return Get.find<ThemeController>().effectiveBrightness == Brightness.dark
        ? kDarkPalette
        : kLightPalette;
  }

  static Color get primary => _effective.primary;
  static Color get primaryContainer => _effective.primaryContainer;
  static Color get tertiary => _effective.tertiary;
  static Color get tertiaryFixedDim => _effective.tertiaryFixedDim;
  static Color get surface => _effective.surface;
  static Color get surfaceContainerLow => _effective.surfaceContainerLow;
  static Color get surfaceContainerLowest => _effective.surfaceContainerLowest;
  static Color get surfaceContainerHigh => _effective.surfaceContainerHigh;
  static Color get onSurface => _effective.onSurface;
  static Color get textSecondary => _effective.textSecondary;
  static Color get outlineVariant => _effective.outlineVariant;
  static Color get secondaryContainer => _effective.secondaryContainer;

  static Color get danger => _effective.danger;
  static Color get dangerDark => _effective.dangerDark;
  static Color get dangerSoft => _effective.dangerSoft;
  static Color get dangerPanel => _effective.dangerPanel;

  static Color get success => _effective.success;
  static Color get successDark => _effective.successDark;
  static Color get successSoft => _effective.successSoft;
  static Color get successPanel => _effective.successPanel;
  static Color get successShadow => _effective.successShadow;

  static Color get skillVocabulary => _effective.skillVocabulary;
  static Color get skillGrammar => _effective.skillGrammar;
  static Color get skillListening => _effective.skillListening;

  static Color get primarySoft => _effective.primarySoft;
  static Color get primarySoftSelected => _effective.primarySoftSelected;
  static Color get neutralShadow => _effective.neutralShadow;
  static Color get iconMuted => _effective.iconMuted;

  static Gradient get primaryGradient => _effective.primaryGradient;
  static Color get recommendationMutedBg => _effective.recommendationMutedBg;
  static Color get chipHighlightBg => _effective.chipHighlightBg;

  /// Nền cam nhẹ cho ô gợi ý — giữ tông ấm, đủ contrast trên dark
  static Color get recommendationOrangeBg => _effective.brightness == Brightness.dark
      ? _effective.tertiaryBgSoft
      : const Color(0xFFFFF3E0);
}

class AppTypography {
  // Headlines: Be Vietnam Pro (Modern Authority)
  static TextStyle get displayLarge => TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Word of the Day: Editorial Intent
  static TextStyle get titleLargeTertiary => TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.tertiary,
  );

  // Body: Plus Jakarta Sans (Friendly apertures)
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.onSurface, // English definitions
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, // Vietnamese translations
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.primary,
  );

  // Alias for semantic naming used in widgets
  static TextStyle get body => bodyLarge;
  static TextStyle get caption => labelMedium;
  static TextStyle get button => labelMedium;

  // Brand wordmark style
  static TextStyle get brand => TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: (_effectiveBrightness() == Brightness.dark ? kDarkPalette : kLightPalette).brandHue,
    letterSpacing: -0.3,
  );

  // Accent display (orange)
  static TextStyle get displayAccent => TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.tertiary,
    letterSpacing: -0.5,
  );

  static Brightness _effectiveBrightness() {
    if (!Get.isRegistered<ThemeController>()) return Brightness.light;
    return Get.find<ThemeController>().effectiveBrightness;
  }
}

ThemeData _buildTheme(AppPaletteColors p) {
  final cs = switch (p.brightness) {
    Brightness.dark => ColorScheme.dark(
      primary: p.primary,
      onPrimary: const Color(0xFF141520),
      secondary: p.secondaryContainer,
      onSecondary: p.onSurface,
      tertiary: p.tertiary,
      surface: p.surface,
      onSurface: p.onSurface,
      error: p.danger,
      outlineVariant: p.outlineVariant,
    ),
    Brightness.light => ColorScheme.light(
      primary: p.primary,
      onPrimary: Colors.white,
      tertiary: p.tertiary,
      surface: p.surface,
      onSurface: p.onSurface,
      error: p.danger,
      outlineVariant: p.outlineVariant,
    ),
  };

  final base = ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    scaffoldBackgroundColor: p.surface,
    colorScheme: cs,
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
  );

  return base.copyWith(
    dividerTheme: const DividerThemeData(
      color: Colors.transparent,
      space: 32,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: p.onSurface,
      iconTheme: IconThemeData(color: p.onSurface),
      titleTextStyle: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: p.onSurface,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor:
            p.brightness == Brightness.dark ? const Color(0xFF151620) : Colors.white,
        backgroundColor: p.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color:
              p.brightness == Brightness.dark ? const Color(0xFF151620) : Colors.white,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: p.primary.withValues(alpha: p.brightness == Brightness.dark ? 0.5 : 0.2),
          width: 2,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: p.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    splashFactory: InkRipple.splashFactory,
    iconTheme: IconThemeData(color: p.onSurface),
  );
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(kLightPalette);

  static ThemeData get darkTheme => _buildTheme(kDarkPalette);
}
