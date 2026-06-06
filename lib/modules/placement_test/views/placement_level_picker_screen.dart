import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

/// Màn cho học viên TỰ CHỌN trình độ CEFR mà không làm bài kiểm tra.
/// Trước khi lưu sẽ hiện dialog cảnh báo lựa chọn này có thể không chính xác.
class PlacementLevelPickerScreen extends GetView<PlacementTestController> {
  const PlacementLevelPickerScreen({super.key});

  static const Map<String, String> _descriptions = {
    'A1': 'Mới bắt đầu — câu chào hỏi, từ vựng cơ bản.',
    'A2': 'Sơ cấp — giao tiếp đơn giản hằng ngày.',
    'B1': 'Trung cấp — xử lý hầu hết tình huống quen thuộc.',
    'B2': 'Trung cao cấp — thảo luận trôi chảy, ý kiến rõ ràng.',
    'C1': 'Cao cấp — dùng tiếng Anh linh hoạt, hiệu quả.',
    'C2': 'Thành thạo — gần như người bản ngữ.',
  };

  static Color _colorFor(String level) {
    return switch (level) {
      'A1' => const Color(0xFF9E9E9E),
      'A2' => const Color(0xFF42A5F5),
      'B1' => const Color(0xFF66BB6A),
      'B2' => const Color(0xFFFFA726),
      'C1' => const Color(0xFFEF5350),
      'C2' => const Color(0xFFAB47BC),
      _ => AppColors.primary,
    };
  }

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
              Row(children: [AppBackButton(onPressed: () => Get.back())]),
              AppGap.h18,
              Text(
                T.placementSelfSelectTitle.tr,
                style: AppTypography.displayLarge.copyWith(fontSize: 24),
              ),
              AppGap.h10,
              Text(
                T.placementSelfSelectSubtitle.tr,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              AppGap.h20,
              Obx(() {
                final selected = controller.selfSelectedLevel.value;
                return Column(
                  children: PlacementTestController.cefrLevels.map((level) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LevelCard(
                        level: level,
                        description: _descriptions[level] ?? '',
                        color: _colorFor(level),
                        selected: selected == level,
                        onTap: () => controller.selectLevel(level),
                      ),
                    );
                  }).toList(),
                );
              }),
              AppGap.h12,
              Obx(() {
                final hasSelection = controller.selfSelectedLevel.value != null;
                return AppButton(
                  label: T.placementSelfSelectConfirm.tr,
                  isLoading: controller.isSelfSelecting.value,
                  onPressed: hasSelection
                      ? () => _confirm(context, controller.selfSelectedLevel.value!)
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, String level) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFA726)),
            AppGap.w10,
            Expanded(
              child: Text(
                T.placementSelfSelectWarnTitle.tr,
                style: AppTypography.displayLarge.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          T.placementSelfSelectWarnBody.tr,
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          AppButton(
            label: T.placementSelfSelectWarnTakeTest,
            variant: AppButtonVariant.text,
            expand: false,
            onPressed: () => Navigator.of(ctx).pop(false),
            textStyle: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppButton(
            label: T.placementSelfSelectWarnProceed,
            variant: AppButtonVariant.text,
            expand: false,
            onPressed: () => Navigator.of(ctx).pop(true),
            textStyle: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (proceed == true) {
      await controller.selfSelectLevel(level);
    } else if (proceed == false) {
      // Người dùng chọn làm bài kiểm tra → quay lại màn intro.
      Get.until((route) => Get.currentRoute == AppRoutes.placementTest);
    }
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.description,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String level;
  final String description;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.10)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? color : AppColors.outlineVariant,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  level,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ),
            ),
            AppGap.w14,
            Expanded(
              child: Text(
                description,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  color: AppColors.onSurface,
                  height: 1.25,
                ),
              ),
            ),
            if (selected) ...[
              AppGap.w8,
              Icon(Icons.check_circle_rounded, color: color, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
