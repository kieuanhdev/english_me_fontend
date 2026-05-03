import 'package:englishme/core/services/localization_service.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalizationService.init();
  Get.put(TtsService());

  runApp(
    GetMaterialApp(
      translations: LocalizationService(),
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
    ),
  );
}
