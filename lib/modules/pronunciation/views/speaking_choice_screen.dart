import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpeakingChoiceScreen extends StatelessWidget {
  const SpeakingChoiceScreen({super.key});

  void _onBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
      return;
    }
    ShellController.goToTab(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(
                title: 'Luyện nói',
                showBack: true,
                showSettings: false,
                horizontalPadding: 0,
                onBack: _onBack,
              ),
              AppGap.h24,
              Text(
                'Chọn phương pháp luyện tập',
                style: AppTypography.headlineMedium.copyWith(fontSize: 20),
              ),
              AppGap.h8,
              Text(
                'Bạn muốn luyện phát âm theo cách nào?',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppGap.h24,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _OptionCard(
                        icon: Icons.translate_rounded,
                        title: 'Bảng IPA',
                        subtitle: 'Học phát âm theo bảng ký hiệu ngữ âm quốc tế',
                        color: AppColors.tertiary,
                        onTap: () => Get.toNamed(AppRoutes.ipa),
                      ),
                      AppGap.h14,
                      _OptionCard(
                        icon: Icons.record_voice_over_rounded,
                        title: 'Luyện tập theo mẫu câu',
                        subtitle: 'Luyện nói với các câu mẫu, được AI chấm điểm',
                        color: AppColors.primary,
                        onTap: () =>
                            Get.toNamed(AppRoutes.pronunciationPractice),
                      ),
                      AppGap.h14,
                      _OptionCard(
                        icon: Icons.forum_rounded,
                        title: 'Hội thoại với AI',
                        subtitle:
                            'Nói chuyện tiếng Anh với AI như một người bạn',
                        color: AppColors.tertiaryFixedDim,
                        onTap: () => Get.toNamed(AppRoutes.conversation),
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              AppGap.w16,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineMedium.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h6,
                    Text(
                      subtitle,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
