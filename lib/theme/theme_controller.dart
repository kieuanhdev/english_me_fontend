import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeController({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _prefKey = 'app_theme_mode';

  SharedPreferences? _prefs;

  final Rx<ThemeMode> themeModeRx = ThemeMode.system.obs;

  ThemeMode get themeMode => themeModeRx.value;

  Brightness get effectiveBrightness {
    switch (themeModeRx.value) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        return SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getInt(_prefKey);
    themeModeRx.value = switch (raw) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final shouldRefresh = themeModeRx.value != mode;
    themeModeRx.value = mode;
    Get.changeThemeMode(mode);
    if (shouldRefresh) {
      await Get.forceAppUpdate();
    }
    _prefs ??= await SharedPreferences.getInstance();
    final int stored = switch (mode) {
      ThemeMode.light => 0,
      ThemeMode.dark => 1,
      ThemeMode.system => 2,
    };
    await _prefs!.setInt(_prefKey, stored);
  }

  Future<void> refreshSystemTheme() async {
    if (themeModeRx.value != ThemeMode.system) return;
    Get.changeThemeMode(ThemeMode.system);
    await Get.forceAppUpdate();
  }
}
