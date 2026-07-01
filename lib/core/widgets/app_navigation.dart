import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    required this.onPressed,
    this.size = 40,
    super.key,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.chevron_left_rounded, color: AppColors.primary),
      ),
    );
  }
}

/// Nút "thoát/hủy" cho luồng đang làm dở (phiên thi, học thẻ, luyện tập).
/// Cùng kiểu dáng tròn border+shadow như [AppBackButton] để đồng bộ giao diện,
/// nhưng icon X — phân biệt ngữ nghĩa "thoát phiên" với "quay lại" ([AppBackButton]).
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({
    required this.onPressed,
    this.size = 40,
    super.key,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.close_rounded, color: AppColors.primary, size: 22),
      ),
    );
  }
}

class AppBackWithProgress extends StatelessWidget {
  const AppBackWithProgress({
    required this.onBack,
    required this.progress,
    this.backButtonSize = 32,
    super.key,
  });

  final VoidCallback onBack;
  final double progress;
  final double backButtonSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(onPressed: onBack, size: backButtonSize),
        AppGap.w12,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFD3DAE2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
