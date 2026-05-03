import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:get/get.dart';

class PlacementIntroScreen extends StatelessWidget {
  const PlacementIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(onBack: () => Navigator.of(context).pop()),
              AppGap.h18,
              const Center(child: _PlacementMascot()),
              AppGap.h16,
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'BÀI KIỂM TRA ĐẦU VÀO',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              AppGap.h14,
              Center(
                child: Text(
                  'Cùng xem trình\nđộ của bạn nhé!',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 23,
                    height: 1.15,
                  ),
                ),
              ),
              AppGap.h10,
              Center(
                child: Text(
                  'Một bài kiểm tra ngắn ~5 phút để hệ thống xếp bạn\nvào lộ trình phù hợp theo chuẩn CEFR (A1-C1).',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(fontSize: 14),
                ),
              ),
              AppGap.h18,
              const Row(
                children: [
                  Expanded(
                    child: _SkillCard(
                      label: 'Ngữ pháp',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.skillGrammar,
                    ),
                  ),
                  AppGap.w10,
                  Expanded(
                    child: _SkillCard(
                      label: 'Từ vựng',
                      icon: Icons.library_books_rounded,
                      color: AppColors.skillVocabulary,
                    ),
                  ),
                  AppGap.w10,
                  Expanded(
                    child: _SkillCard(
                      label: 'Nghe hiểu',
                      icon: Icons.headphones_rounded,
                      color: AppColors.skillListening,
                    ),
                  ),
                ],
              ),
              AppGap.h24,
              AppButton(
                label: 'BẮT ĐẦU KIỂM TRA',
                onPressed: () async {
                  final controller = Get.find<PlacementTestController>();
                  await controller.startTest();
                  if (controller.state.value == PlacementTestState.questioning) {
                    Get.toNamed('/placement-test/question');
                  }
                },
                variant: AppButtonVariant.primary,
              ),
              AppGap.h18,
              Center(
                child: TextButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  child: Text(
                    'Bỏ qua, vào thẳng Dashboard',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(children: [AppBackButton(onPressed: onBack)]);
  }
}

class _PlacementMascot extends StatelessWidget {
  const _PlacementMascot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: AppColors.primaryContainer, width: 4),
              ),
              child: const Icon(
                Icons.flutter_dash,
                size: 76,
                color: AppColors.primarySoft,
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 36,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryContainer, width: 2),
              ),
              child: Center(
                child: Text(
                  '?',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w900,
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

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFCBD5DD),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          AppGap.h8,
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
