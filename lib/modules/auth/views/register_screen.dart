import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/modules/auth/views/login_screen.dart';
import 'package:englishme/modules/auth/views/widgets/auth_navigation_text.dart';
import 'package:englishme/modules/auth/views/widgets/auth_or_divider.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends GetView<AuthController> {
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
              Obx(
                () => AppButton(
                  label: T.registerNow,
                  onPressed: controller.isLoading.value ? null : () {},
                  variant: AppButtonVariant.primary,
                ),
              ),
              AppGap.h24,
              const AuthOrDivider(),
              AppGap.h22,
              Obx(
                () => AppButton(
                  label: T.buttonContinueWithGoogle,
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.signInWithGoogle,
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
              ),
              AppGap.h18,
              AuthNavigationText(
                promptText: T.alreadyHaveAccount.tr,
                buttonText: T.loginNow.tr,
                onTap: () => Get.to(() => const LoginScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
