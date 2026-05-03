import 'package:englishme/modules/auth/bindings/auth_binding.dart';
import 'package:englishme/modules/auth/views/login_screen.dart';
import 'package:englishme/modules/auth/views/register_screen.dart';
import 'package:englishme/modules/flashcard/bindings/flashcard_binding.dart';
import 'package:englishme/modules/flashcard/views/flashcard_screen.dart';
import 'package:englishme/modules/home/bindings/home_binding.dart';
import 'package:englishme/modules/home/views/home_screen.dart';
import 'package:englishme/modules/placement_test/bindings/placement_test_binding.dart';
import 'package:englishme/modules/placement_test/views/placement_intro_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_question_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_result_screen.dart';
import 'package:englishme/modules/study_session/bindings/study_session_binding.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_back_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_front_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/welcome/welcome_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = AppRoutes.welcome;

  static final pages = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.flashcards,
      page: () => const FlashcardScreen(),
      binding: FlashcardBinding(),
    ),
    GetPage(
      name: AppRoutes.placementTest,
      page: () => PlacementIntroScreen(),
      binding: PlacementTestBinding(),
    ),
    GetPage(
      name: AppRoutes.placementTestQuestion,
      page: () => PlacementQuestionScreen(),
      binding: PlacementTestBinding(),
    ),
    GetPage(
      name: AppRoutes.placementTestResult,
      page: () => PlacementResultScreen(),
      binding: PlacementTestBinding(),
    ),
    GetPage(
      name: AppRoutes.studySession,
      page: () => const StudySessionFrontScreen(),
      binding: StudySessionBinding(),
    ),
    GetPage(
      name: AppRoutes.studySessionBack,
      page: () => const StudySessionBackScreen(),
    ),
    GetPage(
      name: AppRoutes.sessionSummary,
      page: () => const SessionSummaryScreen(),
    ),
  ];
}
