import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthNavigationText extends StatelessWidget {
  final String promptText;
  final String buttonText;
  final VoidCallback onTap;

  const AuthNavigationText({
    super.key,
    required this.promptText,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$promptText ',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              buttonText,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
