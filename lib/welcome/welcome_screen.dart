import 'package:flutter/material.dart';
import 'package:englishme/auth/login_screen.dart';
import 'package:englishme/auth/register_screen.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/welcome/styles/welcome_tokens.dart';

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
                  AppGap.h14,
                  _WelcomeDescription(),
                  AppGap.h40,
                  _ActionButtons(),
                  AppGap.h28,
                  _LanguageSwitcher(),
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
    return Text(
      'EnglishMe',
      style: WelcomeTypography.brand,
    );
  }
}

class _MascotIllustration extends StatelessWidget {
  const _MascotIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: WelcomeColors.primary,
        border: Border.all(
          color: WelcomeColors.primaryDark,
          width: 6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22003640),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.flutter_dash,
          size: 96,
          color: WelcomeColors.primarySoft,
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
        Text(
          'Học tiếng Anh miễn phí',
          textAlign: TextAlign.center,
          style: WelcomeTypography.titleMain,
        ),
        AppGap.h6,
        Text(
          'vui hơn mỗi ngày',
          textAlign: TextAlign.center,
          style: WelcomeTypography.titleAccent,
        ),
      ],
    );
  }
}

class _WelcomeDescription extends StatelessWidget {
  const _WelcomeDescription();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Cá nhân hóa theo trình độ. Học từ vựng theo phương pháp\nSM-2, luyện phát âm cùng AI.',
      textAlign: TextAlign.center,
      style: WelcomeTypography.body,
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
          label: 'BẮT ĐẦU',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              ),
            );
          },
          variant: AppButtonVariant.primary,
        ),
        AppGap.h14,
        AppButton(
          label: 'TÔI ĐÃ CÓ TÀI KHOẢN',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
          variant: AppButtonVariant.secondary,
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
        const Icon(
          Icons.language,
          size: 16,
          color: WelcomeColors.textMuted,
        ),
        AppGap.w8,
        Text(
          'Tiếng Việt',
          style: WelcomeTypography.language,
        ),
      ],
    );
  }
}

