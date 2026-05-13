import 'package:englishme/modules/auth/bindings/auth_binding.dart';
import 'package:englishme/modules/auth/views/login_screen.dart';
import 'package:englishme/modules/auth/views/register_screen.dart';
import 'package:englishme/splash/splash_screen.dart';
import 'package:englishme/modules/chat_ai/bindings/chat_ai_binding.dart';
import 'package:englishme/modules/chat_ai/views/chat_ai_screen.dart';
import 'package:englishme/modules/add_flashcard/bindings/add_flashcard_binding.dart';
import 'package:englishme/modules/add_flashcard/views/add_flashcard_screen.dart';
import 'package:englishme/modules/create_desk/bindings/create_desk_binding.dart';
import 'package:englishme/modules/create_desk/views/create_desk_screen.dart';
import 'package:englishme/modules/deck_prep/bindings/deck_prep_binding.dart';
import 'package:englishme/modules/deck_prep/views/deck_prep_screen.dart';
import 'package:englishme/exercise/exercise_screen.dart';
import 'package:englishme/modules/flashcard/bindings/flashcard_binding.dart';
import 'package:englishme/modules/flashcard/views/flashcard_screen.dart';
import 'package:englishme/grammar/grammar_lesson_detail_screen.dart';
import 'package:englishme/grammar/grammar_screen.dart';
import 'package:englishme/modules/home/bindings/home_binding.dart';
import 'package:englishme/modules/home/views/home_screen.dart';
import 'package:englishme/modules/grammar/bindings/grammar_binding.dart';
import 'package:englishme/modules/placement_test/bindings/placement_test_binding.dart';
import 'package:englishme/modules/placement_test/views/placement_intro_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_question_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_result_screen.dart';
import 'package:englishme/modules/pronunciation/bindings/pronunciation_binding.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_screen.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_result_screen.dart';
import 'package:englishme/modules/pronunciation/views/speaking_choice_screen.dart';
import 'package:englishme/modules/pronunciation/views/ipa_screen.dart';
import 'package:englishme/profile/profile_screen.dart';
import 'package:englishme/progress/progress_screen.dart';
import 'package:englishme/test/test_screen.dart';
import 'package:englishme/modules/study_session/bindings/study_session_binding.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_back_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_front_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/welcome/welcome_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = AppRoutes.splash;
  static String _getLessonIdArg(dynamic arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments;
    }
    return '';
  }

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
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
      name: AppRoutes.learn,
      page: () => const FlashcardScreen(),
      binding: FlashcardBinding(),
    ),
    GetPage(
      name: AppRoutes.flashcards,
      page: () => const FlashcardScreen(),
      binding: FlashcardBinding(),
    ),
    GetPage(
      name: AppRoutes.grammar,
      page: () => const GrammarScreen(),
      binding: GrammarBinding(),
    ),
    GetPage(
      name: AppRoutes.grammarLessonDetail,
      page: () => GrammarLessonDetailScreen(
        lessonId: _getLessonIdArg(Get.arguments),
      ),
      binding: GrammarBinding(),
    ),
    GetPage(
      name: AppRoutes.deckPrep,
      page: () => const DeckPrepScreen(),
      binding: DeckPrepBinding(),
    ),
    GetPage(
      name: AppRoutes.addFlashcard,
      page: () => const AddFlashcardScreen(),
      binding: AddFlashcardBinding(),
    ),
    GetPage(
      name: AppRoutes.createDesk,
      page: () => const CreateDeskScreen(),
      binding: CreateDeskBinding(),
    ),
    GetPage(
      name: AppRoutes.exercise,
      page: () => const ExerciseScreen(),
    ),
    GetPage(
      name: AppRoutes.test,
      page: () => const TestScreen(),
    ),
    GetPage(
      name: AppRoutes.chatAi,
      page: () => const ChatAiScreen(),
      binding: ChatAiBinding(),
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
    GetPage(
      name: AppRoutes.pronunciation,
      page: () => const SpeakingChoiceScreen(),
    ),
    GetPage(
      name: AppRoutes.pronunciationPractice,
      page: () => const PronunciationScreen(),
      binding: PronunciationBinding(),
    ),
    GetPage(
      name: AppRoutes.pronunciationResult,
      page: () => const PronunciationResultScreen(),
    ),
    GetPage(
      name: AppRoutes.ipa,
      page: () => const IpaScreen(),
    ),
    GetPage(
      name: AppRoutes.progress,
      page: () => const ProgressScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
  ];
}
