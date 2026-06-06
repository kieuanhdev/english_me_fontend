import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text.dart';
import 'package:englishme/core/widgets/language_toggle_button.dart';
import 'package:englishme/core/widgets/theme_toggle_button.dart';
import 'package:englishme/gen/assets.gen.dart';
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
        centerTitle: true,
        title: const _AppBrand(),
        actions: const [LanguageToggleButton(), ThemeToggleButton(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Spacer(flex: 2),
              _MascotIllustration(),
              Spacer(flex: 2),
              _WelcomeTitle(),
              Spacer(flex: 3),
              _ActionButtons(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBrand extends StatelessWidget {
  const _AppBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Assets.images.iconAppEnglishMe.svg(
          width: 40,
          height: 40,
          semanticsLabel: 'Logo English Me',
        ),
        AppGap.w8,
        AppText(T.appName, style: WelcomeTypography.brand),
      ],
    );
  }
}

class _MascotIllustration extends StatelessWidget {
  const _MascotIllustration();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Assets.images.wellcome.image(
      height: screenHeight * 0.32,
      fit: BoxFit.contain,
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: T.authRegister,
          onPressed: () => Get.toNamed(AppRoutes.register),
        ),
        AppGap.h14,
        AppButton(
          label: T.authLogin,
          onPressed: () => Get.toNamed(AppRoutes.login),
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }
}
