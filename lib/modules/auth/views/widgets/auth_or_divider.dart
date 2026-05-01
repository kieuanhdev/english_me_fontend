import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD6DEE7), thickness: 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'HOẶC',
            style: AppTypography.labelMedium.copyWith(fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD6DEE7), thickness: 2)),
      ],
    );
  }
}
