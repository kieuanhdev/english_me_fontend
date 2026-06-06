import 'package:englishme/core/config/app_config.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/core/widgets/language_toggle_button.dart';
import 'package:englishme/core/widgets/theme_toggle_button.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/modules/auth/views/widgets/auth_form_panel.dart';
import 'package:englishme/modules/auth/views/widgets/auth_navigation_text.dart';
import 'package:englishme/modules/auth/views/widgets/auth_or_divider.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _agreedToTerms = false;

  AuthController get _controller => Get.find<AuthController>();

  Future<void> _openLegalPage(String path) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      AppNotify.error('Lỗi', message: T.termsOpenFailed.tr);
    }
  }

  Widget _buildTermsAgreement() {
    final linkStyle = AppTypography.bodyRegular.copyWith(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
    );
    final baseStyle = AppTypography.bodyRegular.copyWith(
      fontSize: 12,
      color: AppColors.textSecondary,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        AppGap.w8,
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: T.registerAgreePrefix.tr),
                  TextSpan(
                    text: T.registerAgreeTerms.tr,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()..onTap = () => _openLegalPage('/terms'),
                  ),
                  TextSpan(text: T.registerAgreeConjunction.tr),
                  TextSpan(
                    text: T.registerAgreePrivacy.tr,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()..onTap = () => _openLegalPage('/privacy'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
      appBar: const CommonAppBar(
        title: T.authRegister,
        actions: [LanguageToggleButton(), ThemeToggleButton(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthFormPanel(
                child: Column(
                  children: [
                    AppTextField(
                      label: T.labelFullName,
                      controller: _fullNameController,
                    ),
                    AppGap.h10,
                    AppTextField(
                      label: T.labelEmail,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    AppGap.h10,
                    AppTextField(
                      label: T.labelPassword,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    AppGap.h10,
                    AppTextField(
                      label: T.labelConfirmPassword,
                      obscureText: true,
                      controller: _confirmPasswordController,
                    ),
                    AppGap.h12,
                    _buildTermsAgreement(),
                    AppGap.h14,
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
                                  agreedToTerms: _agreedToTerms,
                                ),
                        isLoading: _controller.isLoading.value,
                      ),
                    ),
                    AppGap.h16,
                    const AuthOrDivider(),
                    AppGap.h14,
                    Obx(
                      () => AppButton(
                        label: T.buttonContinueWithGoogle,
                        onPressed: _controller.isLoading.value
                            ? null
                            : _controller.signInWithGoogle,
                        variant: AppButtonVariant.secondary,
                        leading: const GoogleMark(),
                        isLoading: _controller.isLoading.value,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
