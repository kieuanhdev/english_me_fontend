import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để chỉnh System UI
import 'package:get/get.dart';
import 'package:englishme/theme/app_theme.dart';
import 'app_text.dart'; // Sử dụng AppText bạn đã xây dựng

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool isTranslate;
  final Color? backgroundColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.showBackButton = true,
    this.isTranslate = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 1. Chống đổi màu nền khi cuộn danh sách (Lấy từ BaseAppBar)
      surfaceTintColor: Colors.transparent,

      // 2. Cấu hình thanh trạng thái hệ thống cho chuyên nghiệp
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon pin, wifi màu đen
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),

      // 3. Sử dụng AppText để tự động hóa dịch thuật và thống nhất Style
      title: AppText(
        title,
        style: AppTypography.displayLarge.copyWith(fontSize: 18),
        isTranslate: isTranslate,
      ),
      centerTitle: true,

      // 4. Nút quay lại tùy chỉnh hoặc mặc định
      leading: showBackButton
          ? (leading ??
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: onBackPressed ?? () => Get.back(),
                  color: AppColors.onSurface,
                ))
          : null,

      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
