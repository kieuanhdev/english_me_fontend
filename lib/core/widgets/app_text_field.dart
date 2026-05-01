import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Đảm bảo đã import GetX
import 'package:englishme/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.onChanged,
    this.isTranslate = true, // Mặc định là true giống AppButton
  });

  final String? label;
  final String? initialValue;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isTranslate;

  @override
  Widget build(BuildContext context) {
    // Xử lý dịch thuật cho label và hintText
    final String? displayLabel = (isTranslate && label != null)
        ? label!.tr
        : label;
    final String? displayHint = (isTranslate && hintText != null)
        ? hintText!.tr
        : hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayLabel != null) ...[
          Text(
            displayLabel,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.2,
          ),
          decoration: InputDecoration(
            hintText: displayHint, // Sử dụng hint đã dịch
            hintStyle: AppTypography.bodyLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFCED8E2), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
