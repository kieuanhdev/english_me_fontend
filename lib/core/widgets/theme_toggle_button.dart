import 'package:englishme/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() {
      final mode = tc.themeMode;
      return PopupMenuButton<ThemeMode>(
        icon: Icon(_iconFor(tc.effectiveBrightness)),
        tooltip: 'Chọn giao diện',
        onSelected: tc.setThemeMode,
        itemBuilder: (_) => [
          PopupMenuItem(
            value: ThemeMode.light,
            child: _ThemeOption(
              icon: Icons.light_mode_outlined,
              label: 'Sáng',
              selected: mode == ThemeMode.light,
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: _ThemeOption(
              icon: Icons.dark_mode_outlined,
              label: 'Tối',
              selected: mode == ThemeMode.dark,
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.system,
            child: _ThemeOption(
              icon: Icons.brightness_auto_outlined,
              label: 'Hệ thống',
              selected: mode == ThemeMode.system,
            ),
          ),
        ],
      );
    });
  }

  IconData _iconFor(Brightness brightness) {
    final tc = Get.find<ThemeController>();
    return switch (tc.themeMode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).iconTheme.color;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
        if (selected) ...[
          const Spacer(),
          Icon(Icons.check, size: 16, color: color),
        ],
      ],
    );
  }
}
