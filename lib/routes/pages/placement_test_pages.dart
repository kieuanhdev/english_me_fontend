import 'package:englishme/modules/placement_test/bindings/placement_test_binding.dart';
import 'package:englishme/modules/placement_test/views/placement_intro_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_level_picker_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_question_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_result_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class PlacementTestPages {
  static final pages = [
    GetPage(
      name: AppRoutes.placementTest,
      page: () => const PlacementIntroScreen(),
      binding: PlacementTestBinding(),
    ),
    GetPage(
      name: AppRoutes.placementTestQuestion,
      page: () => const PlacementQuestionScreen(),
      binding: PlacementTestBinding(),
    ),
    GetPage(
      name: AppRoutes.placementTestResult,
      page: () => const PlacementResultScreen(),
      binding: PlacementTestBinding(),
    ),
    GetPage(
      name: AppRoutes.placementLevelPicker,
      page: () => const PlacementLevelPickerScreen(),
      binding: PlacementTestBinding(),
    ),
  ];
}
