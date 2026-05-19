import 'package:flutter/material.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

/// Trạng thái thống nhất cho các màn hình gọi API.
/// idle / loading / success / error / empty.
enum ApiState { idle, loading, success, error, empty }

/// View thống nhất cho mọi tab gọi API.
///
/// - `loading` → spinner.
/// - `error` → icon + message + nút "Thử lại".
/// - `empty` → icon + message rỗng (tuỳ chọn).
/// - `success` → render `builder()`.
///
/// Lý do tách: trước đây mỗi screen tự viết riêng → UI không nhất quán khi mạng yếu.
class ApiStateView extends StatelessWidget {
  const ApiStateView({
    super.key,
    required this.state,
    required this.builder,
    this.errorMessage,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
  });

  final ApiState state;
  final WidgetBuilder builder;
  final String? errorMessage;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;

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
    return Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
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
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 14,
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
