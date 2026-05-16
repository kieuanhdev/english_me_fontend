import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_settings_icon_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key});

  void _onBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
      return;
    }
    ShellController.goToTab(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: AppBottomNav(
        initialIndex: 1,
        onTap: (index, _) => ShellController.goToTab(index),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: _onBack),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Pronunciation',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const AppSettingsIconButton(),
                ],
              ),
              AppGap.h24,
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Luyện phát âm',
                        style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                      ),
                      AppGap.h8,
                      Text(
                        'Tính năng đang được hoàn thiện. Bạn có thể quay lại Home hoặc chọn tab khác từ thanh điều hướng bên dưới.',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
