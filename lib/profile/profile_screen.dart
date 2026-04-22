import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/welcome/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              AppGap.h24,
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySoft,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 54,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              AppGap.h16,
              Center(
                child: Text(
                  'Minh Anh',
                  style: AppTypography.displayLarge.copyWith(fontSize: 30),
                ),
              ),
              AppGap.h6,
              Center(
                child: Text(
                  'minhanh@englishme.vn',
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
              ),
              AppGap.h24,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  'Tài khoản của bạn đã được đồng bộ.\nBạn có thể đăng xuất bất kỳ lúc nào.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: AppColors.dangerDark, offset: Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'ĐĂNG XUẤT',
                    style: AppTypography.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
              AppGap.h8,
            ],
          ),
        ),
      ),
    );
  }
}
