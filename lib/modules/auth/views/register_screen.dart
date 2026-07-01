import 'package:englishme/core/config/app_config.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_brand_row.dart';
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

  /// Pop nếu còn route phía dưới; nếu không thì về Welcome (tránh màn trắng).
  void _safeBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

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
      appBar: CommonAppBar(
        title: '',
        titleWidget: const AppBrandRow(),
        isTranslate: false,
        onBackPressed: _safeBack,
        actions: const [
          LanguageToggleButton(),
          ThemeToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: IntrinsicHeight(
                    child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthBrandHeader(
                    title: T.registerWelcomeTitle.tr,
                    subtitle: T.registerWelcomeSubtitle.tr,
                  ),
                  AppGap.h16,
                  AuthFormPanel(
                    child: Column(
                      children: [
                        AppTextField(
                          label: T.labelFullName,
                          controller: _fullNameController,
                        ),
                        AppGap.h8,
                        AppTextField(
                          label: T.labelEmail,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        AppGap.h8,
                        AppTextField(
                          label: T.labelPassword,
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        AppGap.h8,
                        AppTextField(
                          label: T.labelConfirmPassword,
                          obscureText: true,
                          controller: _confirmPasswordController,
                        ),
                        AppGap.h10,
                        _buildTermsAgreement(),
                        AppGap.h14,
                        Obx(
                          () => AppButton(
                            label: T.buttonCreateAccount,
                            gradient: true,
                            radius: AppRadius.pill,
                            onPressed: _controller.isBusy
                                ? null
                                : () => _controller.signUpWithEmail(
                                      _fullNameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                      _confirmPasswordController.text,
                                      agreedToTerms: _agreedToTerms,
                                    ),
                            isLoading: _controller.isLoading.value,
                            textStyle: AuthText.button,
                          ),
                        ),
                        AppGap.h12,
                        const AuthOrDivider(),
                        AppGap.h12,
                        Obx(
                          () => AppButton(
                            label: T.buttonContinueWithGoogle,
                            radius: AppRadius.pill,
                            onPressed: _controller.isBusy
                                ? null
                                : _controller.signInWithGoogle,
                            variant: AppButtonVariant.secondary,
                            leading: const GoogleMark(),
                            isLoading: _controller.isGoogleLoading.value,
                            textStyle: AuthText.button,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppGap.h16,
                  AuthNavigationText(
                    promptText: T.alreadyHaveAccount.tr,
                    buttonText: T.loginNow.tr,
                    onTap: () => Get.toNamed(AppRoutes.login),
                  ),
                ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nền trang trí cho màn auth: 2 khối tròn gradient mờ ở góc.
class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.06),
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
