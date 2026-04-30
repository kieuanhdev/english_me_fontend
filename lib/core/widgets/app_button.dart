import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm GetX để dùng .tr
import 'package:englishme/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 56, // Giảm nhẹ chiều cao cho cân đối
    this.expand = true,
    this.leading,
    this.textStyle,
    this.isLoading = false, // Thêm trạng thái loading
    this.isTranslate = true, // Tích hợp dịch tự động
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final bool expand;
  final Widget? leading;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool isTranslate;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == AppButtonVariant.primary;

    // Xử lý label: Dịch nếu cần
    final String displayLabel = isTranslate ? label.tr : label;

    final Color shadowColor = isPrimary
        ? AppColors.primaryDark
        : AppColors.neutralShadow;

    final TextStyle resolvedTextStyle = (textStyle ?? AppTypography.button)
        .copyWith(color: isPrimary ? Colors.white : AppColors.primary);

    final Widget buttonChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? Colors.white : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(displayLabel, style: resolvedTextStyle),
            ],
          );

    final ButtonStyle style =
        ElevatedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, height),
          backgroundColor: isPrimary ? AppColors.primary : AppColors.surface,
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: AppColors.border, width: 2),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ), // Bo góc tròn hơn chút
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(
            isPrimary
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.05),
          ),
        );

    return Container(
      width: expand ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null || isLoading
            ? null
            : [
                // Tắt bóng khi disable hoặc loading
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
      ),
      child: isPrimary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: buttonChild,
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: buttonChild,
            ),
    );
  }
}
