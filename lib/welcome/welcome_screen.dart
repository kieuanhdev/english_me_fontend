import 'package:englishme/core/widgets/app_text.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:englishme/auth/login_screen.dart';
import 'package:englishme/auth/register_screen.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/welcome/styles/welcome_tokens.dart';
import 'package:get/get.dart';
import '../core/values/app_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WelcomeColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: const Column(
                children: [
                  _AppBrand(),
                  AppGap.h48,
                  _MascotIllustration(),
                  AppGap.h32,
                  _WelcomeTitle(),

                  AppGap.h40,
                  _ActionButtons(),
                  AppGap.h28,
                  // _LanguageSwitcher(),
                ],
              ),
            ),
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
          width: 48,
          height: 48,
          semanticsLabel: 'Logo English Me',
        ),
        AppText(T.appName, style: WelcomeTypography.brand),
      ],
    );
  }
}

class _MascotIllustration extends StatelessWidget {
  const _MascotIllustration();

  @override
  Widget build(BuildContext context) {
    return Assets.images.wellcome.image();
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
          onPressed: () => Get.to(() => const RegisterScreen()),
          variant: AppButtonVariant.primary,
          textStyle: WelcomeTypography.buttonLabel,
        ),
        AppGap.h14,
        AppButton(
          label: T.authLogin,
          onPressed: () => Get.to(() => const LoginScreen()),
          variant: AppButtonVariant.secondary,
          textStyle: WelcomeTypography.buttonLabel,
        ),
      ],
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.language, size: 16, color: WelcomeColors.textMuted),
        AppGap.w8,
        Text('Tiếng Việt', style: WelcomeTypography.language),
      ],
    );
  }
}
