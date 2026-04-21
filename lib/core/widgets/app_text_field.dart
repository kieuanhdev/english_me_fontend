import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
  });

  final String? initialValue;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTypography.body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.0,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.body.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCED8E2), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
