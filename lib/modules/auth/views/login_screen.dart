import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_brand_row.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/modules/auth/views/widgets/auth_form_panel.dart';
import 'package:englishme/modules/auth/views/widgets/auth_navigation_text.dart';
import 'package:englishme/modules/auth/views/widgets/auth_or_divider.dart';
import 'package:englishme/core/widgets/language_toggle_button.dart';
import 'package:englishme/core/widgets/theme_toggle_button.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthController get _controller => Get.find<AuthController>();

  /// Pop nếu còn route phía dưới; nếu không (vd vào login sau logout bằng
  /// offAllNamed → stack rỗng) thì về Welcome thay vì ra màn trắng.
  void _safeBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        // Sau logout dùng offAllNamed → stack rỗng, Get.back() sẽ ra màn trắng.
        // Guard: pop nếu được, không thì về Welcome.
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthBrandHeader(
                    title: T.loginWelcomeTitle.tr,
                    subtitle: T.loginWelcomeSubtitle.tr,
                  ),
                  AppGap.h18,
              AuthFormPanel(
                child: Column(
                  children: [
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
                    AppGap.h6,
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        label: T.forgotPassword,
                        variant: AppButtonVariant.text,
                        expand: false,
                        height: 36,
                        onPressed: () {},
                        textStyle: AppTypography.bodyRegular.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    AppGap.h10,
                    Obx(
                      () => AppButton(
                        label: T.loginNow,
                        gradient: true,
                        radius: AppRadius.pill,
                        onPressed: _controller.isBusy
                            ? null
                            : () => _controller.signInWithEmail(
                                _emailController.text,
                                _passwordController.text,
                              ),
                        isLoading: _controller.isLoading.value,
                        textStyle: AuthText.button,
                      ),
                    ),
                    AppGap.h24,
                    const AuthOrDivider(),
                    AppGap.h22,
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
                  AppGap.h20,
                  AuthNavigationText(
                    promptText: T.dontHaveAccount.tr,
                    buttonText: T.registerNow.tr,
                    onTap: () => Get.toNamed(AppRoutes.register),
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
