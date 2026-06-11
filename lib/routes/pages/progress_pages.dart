import 'package:englishme/modules/progress/bindings/progress_binding.dart';
import 'package:englishme/modules/progress/views/progress_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class ProgressPages {
  static final pages = [
    GetPage(
      name: AppRoutes.progress,
      page: () => const ProgressScreen(),
      binding: ProgressBinding(),
    ),
  ];
}
