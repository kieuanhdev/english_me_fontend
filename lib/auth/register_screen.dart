import 'package:englishme/auth/widgets/auth_navigation_text.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:englishme/auth/login_screen.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/placement/placement_intro_screen.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';

import '../core/values/app_strings.dart';
import '../core/widgets/common_app_bar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommonAppBar(title: T.authRegister),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.images.iconAppEnglishMe.svg(
                width: 80,
                height: 80,
                semanticsLabel: T.appName,
              ),
              AppGap.h26,
              Text(
                T.registerWelcomeTitle.tr,
                style: AppTypography.displayLarge.copyWith(fontSize: 26),
              ),
              Text(
                T.registerWelcomeSubtitle.tr,
                style: AppTypography.bodyLarge.copyWith(fontSize: 14),
              ),
              AppGap.h20,
              const AppTextField(label: T.labelFullName),
              AppGap.h14,
              const AppTextField(
                label: T.labelEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              AppGap.h14,
              const AppTextField(label: T.labelPassword, obscureText: true),
              AppGap.h14,
              const AppTextField(
                label: T.labelConfirmPassword,
                obscureText: true,
              ),
              AppGap.h18,
              AppButton(
                label: 'Tạo tài khoản',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlacementIntroScreen(),
                    ),
                  );
                },
                variant: AppButtonVariant.primary,
              ),
              AppGap.h24,
              const _OrDivider(),
              AppGap.h22,
              AppButton(
                label: T.buttonContinueWithGoogle,
                onPressed: () {},
                variant: AppButtonVariant.secondary,
                leading: const Text(
                  'G',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEA4335),
                  ),
                ),
                textStyle: AppTypography.bodyLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              AppGap.h18,

              AuthNavigationText(
                promptText: T.alreadyHaveAccount.tr,
                buttonText: T.loginNow.tr,
                onTap: () {
                  Get.to(() => const LoginScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD6DEE7), thickness: 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'HOẶC',
            style: AppTypography.labelMedium.copyWith(fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD6DEE7), thickness: 2)),
      ],
    );
  }
}
