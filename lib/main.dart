import 'package:englishme/core/services/localization_service.dart';
import 'package:englishme/dashboard/dashboard_screen.dart';
import 'package:englishme/modules/auth/bindings/auth_binding.dart';
import 'package:englishme/modules/auth/views/login_screen.dart';
import 'package:englishme/modules/auth/views/register_screen.dart';
import 'package:englishme/placement/placement_intro_screen.dart';
import 'package:englishme/welcome/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalizationService.init();

  runApp(
    GetMaterialApp(
      translations: LocalizationService(),
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme,
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => WelcomeScreen()),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: AuthBinding(),
        ),
        GetPage(name: '/placement-test', page: () => PlacementIntroScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
      ],
    ),
  );
}
