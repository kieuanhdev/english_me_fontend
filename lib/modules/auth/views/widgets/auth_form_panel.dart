import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Typography dùng chung cho màn Auth (login/register) — gom 1 chỗ để 2 màn
/// đồng nhất cỡ chữ. Token button mặc định ([AppTypography.labelMedium] = 20px,
/// letterSpacing 1.2) quá to cho form auth, nên ở đây dùng nhãn nút nhỏ hơn.
class AuthText {
  AuthText._();

  /// Tiêu đề welcome ở đầu form (login + register dùng chung cỡ).
  static TextStyle get title => AppTypography.displayLarge.copyWith(
    fontSize: 24,
    color: AppColors.primary,
  );

  /// Dòng phụ dưới tiêu đề.
  static TextStyle get subtitle =>
      AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary);

  /// Nhãn cho mọi nút trong form auth — 16px, spacing nhẹ (gọn hơn token 20px).
  static TextStyle get button => AppTypography.bodyLarge.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
}

/// Header form auth: tiêu đề + dòng phụ.
/// Logo + tên app nằm trên app bar (xem [AppBrandRow]) cho đồng nhất với welcome,
/// nên ở đây KHÔNG lặp lại huy hiệu logo.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AuthText.title),
        AppGap.h4,
        Text(subtitle, style: AuthText.subtitle),
      ],
    );
  }
}

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
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.googleBrand,
      ),
    );
  }
}
