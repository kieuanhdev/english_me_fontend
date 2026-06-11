import 'package:englishme/core/shell/main_shell.dart';
import 'package:englishme/core/shell/shell_binding.dart';
import 'package:englishme/modules/auth/bindings/auth_binding.dart';
import 'package:englishme/modules/home/bindings/home_binding.dart';
import 'package:englishme/modules/learn/bindings/curriculum_binding.dart';
import 'package:englishme/modules/vocab_hub/bindings/vocab_hub_binding.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/splash/splash_screen.dart';
import 'package:englishme/welcome/welcome_screen.dart';
import 'package:get/get.dart';

abstract class CorePages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const MainShellScreen(),
      bindings: [
        ShellBinding(),
        HomeBinding(),
        VocabHubBinding(),
        CurriculumBinding(),
      ],
    ),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeScreen()),
  ];
}
