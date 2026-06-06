import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

/// Unified notification helper — tất cả thông báo dùng TOP, cùng style.
///
/// Dùng thay thế mọi Get.snackbar() rải rác trong app.
/// - [success] — xanh lá, icon check
/// - [error]   — đỏ, icon error
/// - [warning] — vàng/orange, icon warning
/// - [info]    — primary, icon info
abstract class AppNotify {
  static const _margin = EdgeInsets.fromLTRB(16, 12, 16, 0);
  static const _duration = Duration(seconds: 3);

  static void success(String title, {String message = '', IconData? icon}) {
    _show(
      title: title,
      message: message,
      bg: AppColors.success,
      fg: AppColors.onPrimaryFixed,
      icon: icon ?? Icons.check_circle_rounded,
    );
  }

  static void error(String title, {String message = '', IconData? icon}) {
    _show(
      title: title,
      message: message,
      bg: AppColors.danger,
      fg: Colors.white,
      icon: icon ?? Icons.error_rounded,
    );
  }

  static void warning(String title, {String message = '', IconData? icon}) {
    _show(
      title: title,
      message: message,
      bg: AppColors.accentWarm,
      fg: Colors.white,
      icon: icon ?? Icons.warning_rounded,
    );
  }

  static void info(String title, {String message = '', IconData? icon}) {
    _show(
      title: title,
      message: message,
      bg: AppColors.primary,
      fg: AppColors.onPrimaryFixed,
      icon: icon ?? Icons.info_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color bg,
    required Color fg,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: _margin,
      borderRadius: AppRadius.md,
      backgroundColor: bg,
      colorText: fg,
      icon: Icon(icon, color: fg),
      duration: _duration,
    );
  }
}
