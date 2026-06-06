import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm GetX để dùng .tr
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

/// Kiểu nút dùng chung toàn app.
///
/// - [primary]    — nút hành động chính: nền đặc (hoặc gradient nếu [AppButton.gradient]).
/// - [secondary]  — nút phụ: viền, nền surface, chữ primary.
/// - [text]       — nút chữ phẳng, không nền/viền (vai trò như TextButton).
/// - [danger]     — nút hành động nguy hiểm (xoá...): nền/chữ đỏ.
/// - [dangerText] — nút chữ ĐỎ phẳng, không nền/viền (dùng trong dialog: Xoá/Thoát).
enum AppButtonVariant { primary, secondary, text, danger, dangerText }

/// Base button DUY NHẤT của app. Mọi nút hành động nên dùng widget này thay vì
/// FilledButton/ElevatedButton/GestureDetector tự chế, để màu sắc – bo góc –
/// typography – trạng thái disabled/loading luôn đồng nhất và sửa một chỗ.
///
/// Ví dụ:
/// ```dart
/// AppButton(label: 'Bắt đầu', onPressed: ...);                       // primary
/// AppButton(label: 'Huỷ', onPressed: ..., variant: .secondary);     // outline
/// AppButton(label: 'Xoá', onPressed: ..., variant: .danger);        // đỏ
/// AppButton(label: 'Tiếp tục', onPressed: ..., gradient: true,      // gradient pill
///   radius: AppRadius.pill, trailing: Icon(Icons.arrow_forward_rounded));
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 56,
    this.expand = true,
    this.leading,
    this.trailing,
    this.textStyle,
    this.isLoading = false,
    this.isTranslate = true,
    this.gradient = false,
    this.radius,
    super.key,
  });

  /// Nhãn nút. Dịch tự động nếu [isTranslate] = true.
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final bool expand;

  /// Icon/widget trước nhãn.
  final Widget? leading;

  /// Icon/widget sau nhãn (vd mũi tên "tiếp tục").
  final Widget? trailing;

  /// Ghi đè style chữ (color sẽ được tự áp theo variant nếu không set).
  final TextStyle? textStyle;
  final bool isLoading;
  final bool isTranslate;

  /// Dùng nền gradient (chỉ áp cho variant primary/danger có nền đặc).
  final bool gradient;

  /// Bán kính bo góc. Mặc định [AppRadius.lg]; truyền [AppRadius.pill] cho nút bo tròn.
  final double? radius;

  bool get _isFilled =>
      variant == AppButtonVariant.primary || variant == AppButtonVariant.danger;

  /// Màu chữ/icon theo variant.
  Color get _foreground => switch (variant) {
    AppButtonVariant.primary => Colors.white,
    AppButtonVariant.danger => Colors.white,
    AppButtonVariant.secondary => AppColors.primary,
    AppButtonVariant.text => AppColors.primary,
    AppButtonVariant.dangerText => AppColors.danger,
  };

  /// Màu nền (chỉ dùng khi không bật gradient).
  Color get _background => switch (variant) {
    AppButtonVariant.primary => AppColors.primary,
    AppButtonVariant.danger => AppColors.danger,
    AppButtonVariant.secondary => AppColors.surface,
    AppButtonVariant.text => Colors.transparent,
    AppButtonVariant.dangerText => Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    final double r = radius ?? AppRadius.lg;
    final bool disabled = onPressed == null || isLoading;
    final String displayLabel = isTranslate ? label.tr : label;
    final bool useGradient = gradient && _isFilled && !disabled;

    final TextStyle resolvedTextStyle = (textStyle ?? AppTypography.labelMedium)
        .copyWith(color: _foreground);

    final Widget content = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  displayLabel,
                  style: resolvedTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );

    final ButtonStyle style =
        ElevatedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, height),
          // Khi dùng gradient, nền nút trong suốt để lộ gradient của Container ngoài.
          backgroundColor: useGradient ? Colors.transparent : _background,
          foregroundColor: _foreground,
          disabledBackgroundColor: _isFilled
              ? _background.withValues(alpha: 0.4)
              : Colors.transparent,
          disabledForegroundColor: _foreground.withValues(alpha: 0.6),
          side: variant == AppButtonVariant.secondary
              ? BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                )
              : BorderSide.none,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(
            _isFilled
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.05),
          ),
        );

    final Widget button = ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: style,
      child: content,
    );

    return Container(
      width: expand ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: useGradient ? AppColors.primaryGradient : null,
        // Chỉ nút nền đặc (primary/danger) mới có bóng; nút viền & nút phẳng để
        // nhẹ, không đổ bóng.
        boxShadow: disabled || !_isFilled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryContainer,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: button,
    );
  }
}
