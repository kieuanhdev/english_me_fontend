import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeBottomNav extends StatefulWidget {
  const HomeBottomNav({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  late int _currentIndex;

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_rounded, inactiveIcon: Icons.home_outlined, label: 'Home'),
    _NavItemData(icon: Icons.style_rounded, inactiveIcon: Icons.style_outlined, label: 'Flashcards'),
    _NavItemData(icon: Icons.mic_rounded, inactiveIcon: Icons.mic_none_rounded, label: 'Pronunciation'),
    _NavItemData(icon: Icons.smart_toy_rounded, inactiveIcon: Icons.smart_toy_outlined, label: 'Chat AI'),
    _NavItemData(icon: Icons.analytics_rounded, inactiveIcon: Icons.analytics_outlined, label: 'Progress'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
        border: const Border(
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
              onTap: () => setState(() => _currentIndex = i),
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

  const _NavItemData({
    required this.icon,
    required this.inactiveIcon,
    required this.label,
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
    final Color color = active ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.7);

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
                borderRadius: BorderRadius.circular(20),
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
