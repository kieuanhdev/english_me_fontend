import 'package:flutter/material.dart';
import 'package:englishme/welcome/styles/welcome_tokens.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 60,
    this.expand = true,
    this.leading,
    this.textStyle,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final bool expand;
  final Widget? leading;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == AppButtonVariant.primary;
    final Color shadowColor =
        isPrimary ? WelcomeColors.primaryDark : const Color(0xFFCBD5DD);
    final BorderSide borderSide = isPrimary
        ? BorderSide.none
        : const BorderSide(color: WelcomeColors.border, width: 2);

    final TextStyle resolvedTextStyle =
        (textStyle ?? WelcomeTypography.buttonLabel).copyWith(
      color: isPrimary ? Colors.white : WelcomeColors.primary,
    );

    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Text(label, style: resolvedTextStyle),
      ],
    );

    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, height)),
      backgroundColor: WidgetStatePropertyAll(
        isPrimary ? WelcomeColors.primary : WelcomeColors.surface,
      ),
      foregroundColor: WidgetStatePropertyAll(
        isPrimary ? Colors.white : WelcomeColors.primary,
      ),
      side: WidgetStatePropertyAll(borderSide),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      overlayColor: WidgetStatePropertyAll(
        isPrimary
            ? Colors.white.withValues(alpha: 0.08)
            : WelcomeColors.primary.withValues(alpha: 0.06),
      ),
      textStyle: WidgetStatePropertyAll(resolvedTextStyle),
    );

    final Widget button = isPrimary
        ? ElevatedButton(onPressed: onPressed, style: style, child: buttonChild)
        : OutlinedButton(onPressed: onPressed, style: style, child: buttonChild);

    return Container(
      width: expand ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: button,
    );
  }
}
