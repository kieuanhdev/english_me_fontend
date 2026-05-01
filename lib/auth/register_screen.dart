import 'package:flutter/material.dart';
import 'package:englishme/auth/login_screen.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/placement/placement_intro_screen.dart';
import 'package:englishme/theme/app_theme.dart';

import '../core/values/app_strings.dart';
import '../core/widgets/common_app_bar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommonAppBar(title: T.register),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _TopHeader(onBack: () => Navigator.of(context).pop()),
              AppGap.h26,
              Text(
                'Tạo tài khoản',
                style: AppTypography.displayLarge.copyWith(fontSize: 26),
              ),
              Text(
                'Chỉ cần vài bước để bắt đầu học.',
                style: AppTypography.bodyLarge.copyWith(fontSize: 14),
              ),
              AppGap.h20,
              const _FieldLabel('TÊN HIỂN THỊ'),
              AppGap.h6,
              const AppTextField(initialValue: 'Minh Anh'),
              AppGap.h14,
              const _FieldLabel('EMAIL'),
              AppGap.h6,
              const AppTextField(
                initialValue: 'minhanh@englishme.vn',
                keyboardType: TextInputType.emailAddress,
              ),
              AppGap.h14,
              const _FieldLabel('MẬT KHẨU'),
              AppGap.h6,
              const AppTextField(initialValue: '••••••••••', obscureText: true),
              AppGap.h14,
              const _FieldLabel('XÁC NHẬN MẬT KHẨU'),
              AppGap.h6,
              const AppTextField(initialValue: '••••••••••', obscureText: true),
              AppGap.h18,
              AppButton(
                label: 'ĐĂNG KÝ',
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
                label: 'Tiếp tục với Google',
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
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng nhập',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppBackWithProgress(
      onBack: onBack,
      progress: 0.3,
      backButtonSize: 32,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(
        fontSize: 12,
        letterSpacing: 0.8,
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
