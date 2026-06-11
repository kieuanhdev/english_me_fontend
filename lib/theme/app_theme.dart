import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/gen/fonts.gen.dart';
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
    required this.flagRedVN,
    required this.flagBlueUK,
    required this.googleBrand,
    required this.shadowSoft,
    required this.levelABg,
    required this.levelBBg,
    required this.levelCBg,
    required this.levelAFg,
    required this.levelBFg,
    required this.levelCFg,
    required this.statBgWarm,
    required this.statFgWarm,
    required this.statBgCool,
    required this.statFgCool,
    required this.onPrimaryFixed,
    required this.primaryShadow,
    required this.progressTrack,
    required this.accentWarm,
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

  /// Highlight chọn trong form (vd. create_deck)
  final Color chipHighlightBg;

  /// Cờ quốc gia — dùng trong vocabulary_list để gắn nhãn ngôn ngữ
  final Color flagRedVN;
  final Color flagBlueUK;

  /// Brand đỏ Google (chỉ dùng cho nút "Continue with Google")
  final Color googleBrand;

  /// Shadow rất nhạt cho card khi đặt trên surface trắng
  final Color shadowSoft;

  /// Nền + chữ cho badge cấp độ CEFR (A1/A2 → B1/B2 → C1/C2)
  final Color levelABg;
  final Color levelBBg;
  final Color levelCBg;
  final Color levelAFg;
  final Color levelBFg;
  final Color levelCFg;

  /// Cặp màu cho ô thống kê nhanh ở home (warm + cool)
  final Color statBgWarm;
  final Color statFgWarm;
  final Color statBgCool;
  final Color statFgCool;

  /// Foreground cố định trên primary gradient (vd. text trắng trên CTA xanh).
  /// Light: trắng. Dark: vẫn trắng nhưng có thể tinh chỉnh sau.
  final Color onPrimaryFixed;

  /// Shadow cho primary button / chip được chọn
  final Color primaryShadow;

  /// Nền track cho progress bar (study session)
  final Color progressTrack;

  /// Accent nâu ấm cho nội dung từ vựng (word of day, flashcard)
  final Color accentWarm;

  Gradient get primaryGradient =>
      LinearGradient(colors: [primary, primaryContainer]);
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
  flagRedVN: Color(0xFFDA291C),
  flagBlueUK: Color(0xFF012169),
  googleBrand: Color(0xFFEA4335),
  shadowSoft: Color(0x0A1A1C1C),
  levelABg: Color(0xFFDEF7EC),
  levelBBg: Color(0xFFDEE0FF),
  levelCBg: Color(0xFFFFDCBE),
  levelAFg: Color(0xFF1B5E20),
  levelBFg: Color(0xFF24389C),
  levelCFg: Color(0xFF643900),
  statBgWarm: Color(0xFFFFF0E8),
  statFgWarm: Color(0xFFFF6B35),
  statBgCool: Color(0xFFE0F2F1),
  statFgCool: Color(0xFF00897B),
  onPrimaryFixed: Color(0xFFFFFFFF),
  primaryShadow: Color(0x3324389C),
  progressTrack: Color(0xFFC9CFFD),
  accentWarm: Color(0xFF854D00),
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
  flagRedVN: Color(0xFFFF6A60),
  flagBlueUK: Color(0xFF6B8AFF),
  googleBrand: Color(0xFFFF7B72),
  shadowSoft: Color(0x66000000),
  levelABg: Color(0xFF1E3328),
  levelBBg: Color(0xFF222842),
  levelCBg: Color(0xFF3A2A1A),
  levelAFg: Color(0xFF9CE0AC),
  levelBFg: Color(0xFFAAB4FC),
  levelCFg: Color(0xFFFFCC99),
  statBgWarm: Color(0xFF3A2A22),
  statFgWarm: Color(0xFFFF9874),
  statBgCool: Color(0xFF1E3331),
  statFgCool: Color(0xFF4FD1C5),
  onPrimaryFixed: Color(0xFFFFFFFF),
  primaryShadow: Color(0x30AAB4FC),
  progressTrack: Color(0xFF2D3350),
  accentWarm: Color(0xFFFFB870),
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

  static Color get flagRedVN => _effective.flagRedVN;
  static Color get flagBlueUK => _effective.flagBlueUK;
  static Color get googleBrand => _effective.googleBrand;
  static Color get shadowSoft => _effective.shadowSoft;

  static Color get levelABg => _effective.levelABg;
  static Color get levelBBg => _effective.levelBBg;
  static Color get levelCBg => _effective.levelCBg;
  static Color get levelAFg => _effective.levelAFg;
  static Color get levelBFg => _effective.levelBFg;
  static Color get levelCFg => _effective.levelCFg;

  static Color get statBgWarm => _effective.statBgWarm;
  static Color get statFgWarm => _effective.statFgWarm;
  static Color get statBgCool => _effective.statBgCool;
  static Color get statFgCool => _effective.statFgCool;

  static Color get onPrimaryFixed => _effective.onPrimaryFixed;
  static Color get primaryShadow => _effective.primaryShadow;
  static Color get progressTrack => _effective.progressTrack;
  static Color get accentWarm => _effective.accentWarm;

  /// Nền cam nhẹ cho ô gợi ý — giữ tông ấm, đủ contrast trên dark
  static Color get recommendationOrangeBg =>
      _effective.brightness == Brightness.dark
      ? _effective.tertiaryBgSoft
      : const Color(0xFFFFF3E0);
}

class AppTypography {
  static const String _displayFont = FontFamily.baloo2;
  static const String _bodyFont = FontFamily.nunito;

  // Headlines
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: _displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Word of the Day: Editorial Intent
  static TextStyle get titleLargeTertiary => TextStyle(
    fontFamily: _displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.tertiary,
  );

  // Body
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.onSurface, // English definitions
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, // Vietnamese translations
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.primary,
  );

  // ────────────────────────────────────────────────────────────────────
  // Size tokens nhỏ — đại đa số view dùng raw fontSize 10/12/13/14.
  // Thêm token để find/replace dần (xem docs/UI_CONSISTENCY_AUDIT.md §2).
  // ────────────────────────────────────────────────────────────────────

  /// 10pt — micro caption, tag siêu nhỏ trong card (vd. home_continue_learning)
  static TextStyle get labelXSmall => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  /// 12pt — caption, meta info (timestamp, count)
  static TextStyle get labelSmall => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 13pt — body phụ, mô tả ngắn
  static TextStyle get bodySmall => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// 14pt — body chính kích thước nhỏ (list item, definition)
  static TextStyle get bodyRegular => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.onSurface,
  );

  // Alias for semantic naming used in widgets
  static TextStyle get body => bodyLarge;
  static TextStyle get caption => labelMedium;
  static TextStyle get button => labelMedium;

  // Brand wordmark style
  static TextStyle get brand => TextStyle(
    fontFamily: _displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color:
        (_effectiveBrightness() == Brightness.dark
                ? kDarkPalette
                : kLightPalette)
            .brandHue,
    letterSpacing: -0.3,
  );

  // Accent display (orange)
  static TextStyle get displayAccent => TextStyle(
    fontFamily: _displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.tertiary,
    letterSpacing: -0.5,
  );

  /// Phiên âm IPA — dùng NotoSans (đủ glyph ə ɪ ʃ θ ˈ ˌ ː...).
  /// Baloo2/Nunito thiếu IPA extended nên render lỗi font; style này thay thế
  /// cho mọi chỗ hiển thị phiên âm. Cỡ/màu copyWith tại nơi dùng.
  static TextStyle get ipa => TextStyle(
    fontFamily: FontFamily.notoSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
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
    textTheme: base.textTheme.apply(
      fontFamily: FontFamily.nunito,
      bodyColor: p.onSurface,
      displayColor: p.onSurface,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamily: FontFamily.nunito,
      bodyColor: p.onSurface,
      displayColor: p.onSurface,
    ),

    dividerTheme: const DividerThemeData(color: Colors.transparent, space: 32),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: p.onSurface,
      iconTheme: IconThemeData(color: p.onSurface),
      titleTextStyle: TextStyle(
        fontFamily: FontFamily.baloo2,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: p.onSurface,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: p.brightness == Brightness.dark
            ? const Color(0xFF151620)
            : Colors.white,
        backgroundColor: p.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        textStyle: TextStyle(
          fontFamily: FontFamily.nunito,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: p.brightness == Brightness.dark
              ? const Color(0xFF151620)
              : Colors.white,
        ),
      ),
    ),

    // Đồng bộ FilledButton với ElevatedButton: cùng màu primary, chữ trắng/dark,
    // bo góc lg. Trước đây thiếu theme này nên FilledButton dùng style Material
    // mặc định (bo stadium, lệch tông) — gây lỗi UI ở nút "Luyện đánh vần".
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: p.brightness == Brightness.dark
            ? const Color(0xFF151620)
            : Colors.white,
        backgroundColor: p.primary,
        disabledBackgroundColor: p.primary.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: const TextStyle(
          fontFamily: FontFamily.nunito,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: p.primary.withValues(
            alpha: p.brightness == Brightness.dark ? 0.5 : 0.2,
          ),
          width: 2,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: p.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
    ),

    splashFactory: InkRipple.splashFactory,
    iconTheme: IconThemeData(color: p.onSurface),
  );
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(kLightPalette);

  static ThemeData get darkTheme => _buildTheme(kDarkPalette);
}
