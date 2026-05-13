import 'package:englishme/app.dart';
import 'package:englishme/core/locale_controller.dart';
import 'package:englishme/core/services/localization_service.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/theme/theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalizationService.init();
  final themeController = ThemeController();
  await themeController.load();
  Get.put(themeController, permanent: true);
  Get.put(AppLocaleController(), permanent: true);
  Get.put(TtsService());

  runApp(const EnglishMeApp());
}
