import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/modules/auth/views/widgets/auth_navigation_text.dart';
import 'package:englishme/modules/auth/views/widgets/auth_or_divider.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegisterView();
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AuthController get _controller => Get.find<AuthController>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              AppTextField(
                label: T.labelFullName,
                controller: _fullNameController,
              ),
              AppGap.h14,
              AppTextField(
                label: T.labelEmail,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              AppGap.h14,
              AppTextField(
                label: T.labelPassword,
                obscureText: true,
                controller: _passwordController,
              ),
              AppGap.h14,
              AppTextField(
                label: T.labelConfirmPassword,
                obscureText: true,
                controller: _confirmPasswordController,
              ),
              AppGap.h18,
              Obx(
                () => AppButton(
                  label: T.buttonCreateAccount,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () => _controller.signUpWithEmail(
                            _fullNameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _confirmPasswordController.text,
                          ),
                  variant: AppButtonVariant.primary,
                ),
              ),
              AppGap.h24,
              const AuthOrDivider(),
              AppGap.h22,
              Obx(
                () => AppButton(
                  label: T.buttonContinueWithGoogle,
                  onPressed: _controller.isLoading.value
                      ? null
                      : _controller.signInWithGoogle,
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
                onTap: () => Get.toNamed('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
