import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

/// Bottom navigation bar dùng chung cho shell và màn phụ.
///
/// - Trong shell: [initialIndex] bị bỏ qua, widget tự listen [ShellController]
///   reactive — không cần Obx bọc ngoài, không rebuild widget tree ngoài.
/// - Màn phụ (push trên shell): truyền [initialIndex] cố định (vd 2) để
///   highlight đúng tab nguồn. [onTap] gọi [ShellController.goToTab] để pop
///   về shell rồi switch tab.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.initialIndex = 0, this.onTap});

  final int initialIndex;
  final void Function(int index, String route)? onTap;

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Trang chủ',
      route: AppRoutes.home,
    ),
    _NavItemData(
      icon: Icons.school_rounded,
      inactiveIcon: Icons.school_outlined,
      label: 'Học',
      route: AppRoutes.learn,
    ),
    _NavItemData(
      icon: Icons.bar_chart_rounded,
      inactiveIcon: Icons.bar_chart_outlined,
      label: 'Tiến trình',
      route: AppRoutes.progress,
    ),
    _NavItemData(
      icon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'Hồ sơ',
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final shell = Get.isRegistered<ShellController>()
        ? Get.find<ShellController>()
        : null;

    // Nếu ShellController tồn tại (đang trong shell hoặc màn phụ push từ shell)
    // → dùng Obx để reactive theo currentTab.
    // Nếu không (standalone/test) → dùng initialIndex tĩnh.
    if (shell != null) {
      return Obx(() => _buildBar(shell.currentTab.value, shell));
    }
    return _buildBar(initialIndex, null);
  }

  Widget _buildBar(int activeIndex, ShellController? shell) {
    void handleTap(int i, String route) {
      if (onTap != null) {
        onTap!(i, route);
      } else if (shell != null) {
        ShellController.goToTab(i);
      } else {
        Get.offAllNamed(route);
      }
    }

    // Floating pill bar — cách mép màn, bo tròn lớn, nổi khối với shadow mềm.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutralShadow.withValues(alpha: 0.55),
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              return _NavItem(
                data: item,
                active: i == activeIndex,
                onTap: () => handleTap(i, item.route),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData inactiveIcon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.inactiveIcon,
    required this.label,
    required this.route,
  });
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Active: pill primary, icon + label nằm ngang. Inactive: chỉ icon, mờ.
    final Color iconColor = active
        ? AppColors.onPrimaryFixed
        : AppColors.textSecondary.withValues(alpha: 0.75);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: active
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 9)
            : const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? data.icon : data.inactiveIcon,
              color: iconColor,
              size: 24,
            ),
            // Label chỉ hiện khi active — animated mở rộng theo pill.
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        data.label,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryFixed,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
