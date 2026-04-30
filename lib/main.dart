import 'package:englishme/core/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/welcome/welcome_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.init(); // Quan trọng: Phải đợi load xong JSON

  runApp(
    GetMaterialApp(
      translations: LocalizationService(),
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme,
      home: WelcomeScreen(),
    ),
  );
}
