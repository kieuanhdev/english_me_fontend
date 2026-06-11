import 'package:englishme/modules/exercise/bindings/exercise_binding.dart';
import 'package:englishme/modules/exercise/views/exercise_quiz_screen.dart';
import 'package:englishme/modules/exercise/views/exercise_result_screen.dart';
import 'package:englishme/modules/exercise/views/exercise_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class ExercisePages {
  static final pages = [
    GetPage(
      name: AppRoutes.exercise,
      page: () => const ExerciseScreen(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.exerciseQuiz,
      page: () => const ExerciseQuizScreen(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.exerciseResult,
      page: () => const ExerciseResultScreen(),
      binding: ExerciseBinding(),
    ),
  ];
}
