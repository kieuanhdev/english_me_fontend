import 'package:englishme/core/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<AppLocaleController>();
    return Obx(() {
      final isVi = lc.isVietnamese;
      return PopupMenuButton<String>(
        tooltip: 'Chọn ngôn ngữ',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVi ? '🇻🇳' : '🇬🇧',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
        onSelected: (code) {
          if (code == 'vi') {
            lc.setLocale(const Locale('vi', 'VN'));
          } else {
            lc.setLocale(const Locale('en', 'US'));
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'vi',
            child: _LangOption(
              flag: '🇻🇳',
              label: 'Tiếng Việt',
              selected: isVi,
            ),
          ),
          PopupMenuItem(
            value: 'en',
            child: _LangOption(
              flag: '🇬🇧',
              label: 'English',
              selected: !isVi,
            ),
          ),
        ],
      );
    });
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.flag,
    required this.label,
    required this.selected,
  });

  final String flag;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).iconTheme.color;
    return Row(
      children: [
        Text(flag, style: const TextStyle(fontSize: 18)),
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
