import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/theme/app_theme.dart';
import 'app_text.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.showBackButton = true,
    this.isTranslate = true,
    this.backgroundColor,
  });

  final String title;

  /// Nếu set, dùng widget này làm title thay cho chuỗi [title]
  /// (vd hàng logo + tên app ở màn auth).
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool isTranslate;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      centerTitle: false,
      titleSpacing: showBackButton ? 4 : 20,
      leadingWidth: showBackButton ? 64 : 0,
      leading: showBackButton
          ? (leading ??
                Center(
                  child: AppBackButton(
                    onPressed: onBackPressed ?? () => Get.back(),
                  ),
                ))
          : null,
      title: titleWidget ??
          AppText(
            title,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
            isTranslate: isTranslate,
          ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
