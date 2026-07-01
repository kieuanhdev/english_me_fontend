import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_brand_row.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text.dart';
import 'package:englishme/core/widgets/language_toggle_button.dart';
import 'package:englishme/core/widgets/theme_toggle_button.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/welcome/styles/welcome_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WelcomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const AppBrandRow(),
        actions: const [
          LanguageToggleButton(),
          ThemeToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          const _WelcomeBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Spacer(flex: 2),
                  _MascotIllustration(),
                  Spacer(flex: 2),
                  _WelcomeTitle(),
                  AppGap.h20,
                  _FeatureChips(),
                  Spacer(flex: 3),
                  _ActionButtons(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nền trang trí: 2 khối tròn gradient mờ ở góc cho sinh động.
class _WelcomeBackdrop extends StatelessWidget {
  const _WelcomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -90,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -120,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MascotIllustration extends StatelessWidget {
  const _MascotIllustration();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Mascot đặt trong vòng tròn gradient mờ -> nổi khối, đỡ trơ.
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.14),
              AppColors.primary.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Assets.images.wellcome.image(
          height: screenHeight * 0.28,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          T.welcomeTitle,
          textAlign: TextAlign.center,
          style: WelcomeTypography.titleMain,
        ),
        AppGap.h6,
        AppText(
          T.welcomeSubtitle,
          textAlign: TextAlign.center,
          style: WelcomeTypography.body,
        ),
      ],
    );
  }
}

/// 3 điểm nổi bật của app — chip nhỏ tạo điểm nhấn, không tốn nhiều chiều cao.
class _FeatureChips extends StatelessWidget {
  const _FeatureChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: const [
        _Chip(icon: Icons.style_rounded, label: 'Flashcard SM-2'),
        _Chip(icon: Icons.record_voice_over_rounded, label: 'Phát âm AI'),
        _Chip(icon: Icons.insights_rounded, label: 'Lộ trình CEFR'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          AppGap.w6,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: T.authRegister,
          gradient: true,
          radius: AppRadius.pill,
          trailing: Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: AppColors.onPrimaryFixed,
          ),
          onPressed: () => Get.toNamed(AppRoutes.register),
        ),
        AppGap.h14,
        AppButton(
          label: T.authLogin,
          radius: AppRadius.pill,
          onPressed: () => Get.toNamed(AppRoutes.login),
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }
}
