import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    super.key,
    this.initialIndex = 0,
    this.onTap,
  });

  final int initialIndex;
  final void Function(int index, String route)? onTap;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  late int _currentIndex;

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
      icon: Icons.extension_rounded,
      inactiveIcon: Icons.extension_outlined,
      label: 'Học bổ trợ',
      route: AppRoutes.learningSupport,
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
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant AppBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex &&
        widget.initialIndex != _currentIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  void switchTo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            offset: const Offset(0, -4),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final bool active = i == _currentIndex;
          return Expanded(
            child: _NavItem(
              data: item,
              active: active,
              onTap: () {
                if (i == _currentIndex) return;
                setState(() => _currentIndex = i);
                if (widget.onTap != null) {
                  widget.onTap!(i, item.route);
                } else {
                  Get.offAllNamed(item.route);
                }
              },
            ),
          );
        }),
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
    final Color color = active
        ? AppColors.primary
        : AppColors.textSecondary.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: active
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 4)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: active ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                active ? data.icon : data.inactiveIcon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 9,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
