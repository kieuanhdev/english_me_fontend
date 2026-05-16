import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/profile/views/widgets/achievement_section.dart';
import 'package:englishme/modules/profile/views/widgets/profile_header.dart';
import 'package:englishme/modules/profile/views/widgets/settings_section.dart';
import 'package:englishme/theme/app_theme.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          if (controller.loadState.value == ProfileLoadState.loading) {
            return const _LoadingState();
          }
          if (controller.loadState.value == ProfileLoadState.error) {
            return _ErrorState(onRetry: controller.loadProfile);
          }
          final user = controller.user.value;
          if (user == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.loadProfile,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hồ sơ',
                        style: AppTypography.displayLarge.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  AppGap.h16,
                  ProfileHeader(user: user),
                  AppGap.h20,
                  AchievementSection(badges: user.badges),
                  AppGap.h20,
                  const SettingsSection(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          AppGap.h16,
          Text(
            'Đang tải hồ sơ...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_off_rounded, size: 56, color: AppColors.textSecondary),
            AppGap.h16,
            Text(
              'Không thể tải hồ sơ',
              style: AppTypography.headlineMedium.copyWith(color: AppColors.onSurface),
            ),
            AppGap.h8,
            Text(
              'Kiểm tra kết nối mạng và thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            AppGap.h20,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
