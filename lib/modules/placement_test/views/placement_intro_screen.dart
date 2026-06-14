import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
import 'package:englishme/routes/app_routes.dart';
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(
                title: 'Kiểm tra trình độ',
                horizontalPadding: 0,
                showBack: true,
                showNotification: false,
                showSettings: false,
                onBack: () => Navigator.of(context).pop(),
              ),
              AppGap.h18,
              Text(
                'Cùng xem trình độ của bạn nhé!',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 23,
                  height: 1.15,
                ),
              ),
              AppGap.h8,
              Text(
                'Một bài kiểm tra thích ứng (tối đa 15 câu ngữ pháp + từ vựng): độ khó tự điều chỉnh theo câu trả lời để xếp bạn vào lộ trình phù hợp theo chuẩn CEFR.',
                style: AppTypography.bodyLarge.copyWith(fontSize: 14),
              ),
              AppGap.h18,
              Row(
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
                      label: 'Đọc hiểu',
                      icon: Icons.chrome_reader_mode_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              AppGap.h18,
              const _CapNotice(),
              AppGap.h24,
              AppButton(
                label: 'BẮT ĐẦU KIỂM TRA',
                onPressed: () async {
                  final controller = Get.find<PlacementTestController>();
                  await controller.startTest();
                  if (controller.state.value ==
                      PlacementTestState.questioning) {
                    Get.toNamed(AppRoutes.placementTestQuestion);
                  }
                },
              ),
              AppGap.h18,
              Center(
                child: AppButton(
                  label: T.placementSelfSelectEntry,
                  variant: AppButtonVariant.text,
                  expand: false,
                  onPressed: () => Get.toNamed(AppRoutes.placementLevelPicker),
                  textStyle: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
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

/// Banner cảnh báo: bài đầu vào chỉ xác định trình độ tối đa tới B2.
/// Ưu tiên dùng [notice] từ backend; fallback chuỗi tĩnh nếu rỗng.
class _CapNotice extends StatelessWidget {
  const _CapNotice();

  static const String _fallback =
      'Bài kiểm tra điều chỉnh độ khó theo từng câu trả lời của bạn (tối đa 15 câu) '
      'và xác định trình độ theo chuẩn CEFR từ A1 đến C1. Câu càng về sau càng phản '
      'ánh đúng năng lực thật, nên hãy cố gắng trả lời thật chính xác nhé!';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlacementTestController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 20, color: AppColors.primaryContainer),
          AppGap.w10,
          Expanded(
            child: Obx(
              () => Text(
                controller.notice.value.isNotEmpty
                    ? controller.notice.value
                    : _fallback,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w500,
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 14,
            offset: const Offset(0, 4),
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
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.onPrimaryFixed, size: 22),
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
