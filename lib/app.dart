import 'dart:async';

import 'package:englishme/core/locale_controller.dart';
import 'package:englishme/core/services/localization_service.dart';
import 'package:englishme/routes/app_pages.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EnglishMeApp extends StatefulWidget {
  const EnglishMeApp({super.key});

  @override
  State<EnglishMeApp> createState() => _EnglishMeAppState();
}

class _EnglishMeAppState extends State<EnglishMeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final ThemeController c = Get.find<ThemeController>();
    if (c.themeModeRx.value == ThemeMode.system) {
      unawaited(c.refreshSystemTheme());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController c = Get.find<ThemeController>();
    final AppLocaleController loc = Get.find<AppLocaleController>();
    return Obx(() {
      c.themeModeRx.value;
      loc.localeRx.value;
      return GetMaterialApp(
        translations: LocalizationService(),
        locale: loc.localeRx.value,
        fallbackLocale: const Locale('en', 'US'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: c.themeModeRx.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
      );
    });
  }
}
