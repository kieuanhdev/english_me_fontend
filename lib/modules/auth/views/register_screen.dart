import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/modules/auth/views/widgets/auth_form_panel.dart';
import 'package:englishme/modules/auth/views/widgets/auth_navigation_text.dart';
import 'package:englishme/modules/auth/views/widgets/auth_or_divider.dart';
import 'package:englishme/routes/app_routes.dart';
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
      appBar: const CommonAppBar(title: T.authRegister),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Assets.images.iconAppEnglishMe.svg(
                  width: 76,
                  height: 76,
                  semanticsLabel: T.appName,
                ),
              ),
              AppGap.h20,
              Text(
                T.registerWelcomeTitle.tr,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 26,
                  color: AppColors.primary,
                ),
              ),
              AppGap.h6,
              Text(
                T.registerWelcomeSubtitle.tr,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppGap.h20,
              AuthFormPanel(
                child: Column(
                  children: [
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
                        isLoading: _controller.isLoading.value,
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
                        leading: const GoogleMark(),
                        isLoading: _controller.isLoading.value,
                        textStyle: AppTypography.bodyRegular.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,
              AuthNavigationText(
                promptText: T.alreadyHaveAccount.tr,
                buttonText: T.loginNow.tr,
                onTap: () => Get.toNamed(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
