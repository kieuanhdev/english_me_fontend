import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/profile/views/widgets/achievement_section.dart';
import 'package:englishme/modules/profile/views/widgets/profile_header.dart';
import 'package:englishme/modules/profile/views/widgets/settings_section.dart';
import 'package:englishme/theme/app_theme.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  ApiState _mapState(ProfileLoadState s, ProfileController c) {
    switch (s) {
      case ProfileLoadState.idle:
      case ProfileLoadState.loading:
        return ApiState.loading;
      case ProfileLoadState.error:
        return ApiState.error;
      case ProfileLoadState.success:
        return c.user.value == null ? ApiState.empty : ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          final state = _mapState(controller.loadState.value, controller);
          return ApiStateView(
            state: state,
            errorMessage: 'Không thể tải hồ sơ. Kiểm tra kết nối mạng.',
            emptyMessage: 'Chưa có dữ liệu hồ sơ.',
            onRetry: controller.loadProfile,
            builder: (_) {
              final user = controller.user.value!;
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
            },
          );
        }),
      ),
    );
  }
}
