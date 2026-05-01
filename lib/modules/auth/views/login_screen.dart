import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/modules/auth/views/register_screen.dart';
import 'package:englishme/modules/auth/views/widgets/auth_navigation_text.dart';
import 'package:englishme/modules/auth/views/widgets/auth_or_divider.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommonAppBar(title: T.authLogin),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGap.h26,
              Text(
                T.loginWelcomeTitle.tr,
                style: AppTypography.displayLarge.copyWith(fontSize: 26),
              ),
              Text(
                T.loginWelcomeSubtitle.tr,
                style: AppTypography.bodyLarge.copyWith(fontSize: 14),
              ),
              AppGap.h20,
              const AppTextField(
                label: T.labelEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              AppGap.h14,
              const AppTextField(label: T.labelPassword, obscureText: true),
              AppGap.h8,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    T.forgotPassword.tr,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              AppGap.h10,
              Obx(
                () => AppButton(
                  label: T.loginNow,
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
                  textStyle: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppGap.h18,
              AuthNavigationText(
                promptText: T.dontHaveAccount.tr,
                buttonText: T.registerNow.tr,
                onTap: () => Get.to(() => const RegisterScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
