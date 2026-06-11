import 'package:englishme/modules/test/bindings/test_binding.dart';
import 'package:englishme/modules/test/views/test_home_screen.dart';
import 'package:englishme/modules/test/views/test_question_screen.dart';
import 'package:englishme/modules/test/views/test_result_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class TestPages {
  static final pages = [
    GetPage(
      name: AppRoutes.test,
      page: () => const TestHomeScreen(),
      binding: TestBinding(),
    ),
    GetPage(
      name: AppRoutes.testQuestion,
      page: () => const TestQuestionScreen(),
      binding: TestBinding(),
    ),
    GetPage(
      name: AppRoutes.testResult,
      page: () => const TestResultScreen(),
      binding: TestBinding(),
    ),
  ];
}
