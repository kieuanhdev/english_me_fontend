import 'package:flutter/material.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/theme/app_theme.dart';

/// Trạng thái thống nhất cho các màn hình gọi API.
/// idle / loading / success / error / empty.
enum ApiState { idle, loading, success, error, empty }

/// View thống nhất cho mọi tab gọi API.
///
/// - `loading` → spinner.
/// - `error` → icon + message + nút "Thử lại" + nút "Quay lại".
/// - `empty` → icon + message rỗng (tuỳ chọn).
/// - `success` → render `builder()`.
///
/// Lý do tách: trước đây mỗi screen tự viết riêng → UI không nhất quán khi mạng yếu.
/// Mọi màn hình lỗi dùng chung `_ErrorView` này để giao diện báo lỗi thống nhất.
class ApiStateView extends StatelessWidget {
  const ApiStateView({
    super.key,
    required this.state,
    required this.builder,
    this.errorMessage,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
    this.onBack,
  });

  final ApiState state;
  final WidgetBuilder builder;
  final String? errorMessage;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;

  /// Hành động khi bấm "Quay lại". Nếu null → tự dùng [Navigator.maybePop].
  /// Nút chỉ hiện khi thật sự có trang trước để quay về (canPop).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ApiState.idle:
      case ApiState.loading:
        return const _LoadingView();
      case ApiState.error:
        return _ErrorView(
          message: errorMessage ?? 'Đã xảy ra lỗi. Vui lòng thử lại.',
          onRetry: onRetry,
          onBack: onBack,
        );
      case ApiState.empty:
        return _EmptyView(
          message: emptyMessage ?? 'Không có dữ liệu.',
          icon: emptyIcon ?? Icons.inbox_outlined,
        );
      case ApiState.success:
        return builder(context);
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry, this.onBack});

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // Chỉ hiện nút "Quay lại" khi thật sự có trang trước (ẩn ở tab gốc).
    final canGoBack = onBack != null || Navigator.of(context).canPop();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'Thử lại',
                isTranslate: false,
                onPressed: onRetry,
                expand: false,
                height: 48,
                radius: AppRadius.pill,
                leading: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
            if (canGoBack) ...[
              const SizedBox(height: 10),
              AppButton(
                label: 'Quay lại',
                isTranslate: false,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                variant: AppButtonVariant.text,
                expand: false,
                height: 44,
                leading: Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                textStyle: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.iconMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
