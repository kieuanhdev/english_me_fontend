import 'package:englishme/modules/vocab_hub/bindings/vocab_hub_binding.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_hub_screen.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_topic_list_screen.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_word_list_screen.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_spelling_screen.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_spelling_result_screen.dart';
import 'package:englishme/modules/test/bindings/test_binding.dart';
import 'package:englishme/modules/test/views/test_home_screen.dart';
import 'package:englishme/modules/test/views/test_question_screen.dart';
import 'package:englishme/modules/test/views/test_result_screen.dart';
import 'package:englishme/core/shell/main_shell.dart';
import 'package:englishme/core/shell/shell_binding.dart';
import 'package:englishme/modules/exercise/bindings/exercise_binding.dart';
import 'package:englishme/modules/exercise/views/exercise_quiz_screen.dart';
import 'package:englishme/modules/exercise/views/exercise_result_screen.dart';
import 'package:englishme/modules/exercise/views/exercise_screen.dart';
import 'package:englishme/modules/auth/bindings/auth_binding.dart';
import 'package:englishme/modules/auth/views/login_screen.dart';
import 'package:englishme/modules/auth/views/register_screen.dart';
import 'package:englishme/splash/splash_screen.dart';
import 'package:englishme/modules/add_flashcard/bindings/add_flashcard_binding.dart';
import 'package:englishme/modules/add_flashcard/views/add_flashcard_screen.dart';
import 'package:englishme/modules/create_desk/bindings/create_desk_binding.dart';
import 'package:englishme/modules/create_desk/views/create_desk_screen.dart';
import 'package:englishme/modules/deck_prep/bindings/deck_prep_binding.dart';
import 'package:englishme/modules/deck_prep/views/deck_prep_screen.dart';

import 'package:englishme/modules/grammar/views/grammar_lesson_detail_screen.dart';
import 'package:englishme/modules/grammar/views/grammar_screen.dart';
import 'package:englishme/modules/home/bindings/home_binding.dart';
import 'package:englishme/modules/grammar/bindings/grammar_binding.dart';
import 'package:englishme/modules/learn/bindings/learning_binding.dart';
import 'package:englishme/modules/learn/views/learning_lesson_detail_screen.dart';
import 'package:englishme/modules/learn/views/learning_path_detail_screen.dart';
import 'package:englishme/modules/learn/views/learning_screen.dart';
import 'package:englishme/modules/learn/views/learning_skill_lessons_screen.dart';
import 'package:englishme/modules/learn/views/learning_support_screen.dart';
import 'package:englishme/modules/placement_test/bindings/placement_test_binding.dart';
import 'package:englishme/modules/placement_test/views/placement_intro_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_question_screen.dart';
import 'package:englishme/modules/placement_test/views/placement_result_screen.dart';
import 'package:englishme/modules/pronunciation/bindings/pronunciation_binding.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_screen.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_result_screen.dart';
import 'package:englishme/modules/pronunciation/views/speaking_choice_screen.dart';
import 'package:englishme/modules/pronunciation/views/ipa_screen.dart';
import 'package:englishme/modules/profile/bindings/profile_binding.dart';
import 'package:englishme/modules/profile/views/profile_screen.dart';
import 'package:englishme/modules/progress/bindings/progress_binding.dart';
import 'package:englishme/modules/progress/views/progress_screen.dart';
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

  static Map<String, dynamic> _getMapArg(dynamic arguments) {
    if (arguments is Map<String, dynamic>) return arguments;
    return const {};
  }

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
        LearningBinding(),
      ],
    ),
    GetPage(name: AppRoutes.welcome, page: () => WelcomeScreen()),
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
      name: AppRoutes.flashcards,
      page: () => const VocabHubScreen(),
      binding: VocabHubBinding(),
    ),
    GetPage(
      name: AppRoutes.vocabHub,
      page: () => const VocabHubScreen(),
      binding: VocabHubBinding(),
    ),
    GetPage(
      name: AppRoutes.learn,
      page: () => const LearningScreen(),
      binding: LearningBinding(),
    ),
    GetPage(
      name: AppRoutes.learningSupport,
      page: () => const LearningSupportScreen(),
      binding: LearningBinding(),
    ),
    GetPage(
      name: AppRoutes.learningPathDetail,
      page: () {
        final args = _getMapArg(Get.arguments);
        return LearningPathDetailScreen(
          level: (args['level'] ?? 'A1').toString(),
          pathId: (args['pathId'] ?? '').toString(),
        );
      },
      binding: LearningBinding(),
    ),
    GetPage(
      name: AppRoutes.learningSkillLessons,
      page: () {
        final args = _getMapArg(Get.arguments);
        return LearningSkillLessonsScreen(
          level: (args['level'] ?? 'A1').toString(),
          skill: (args['skill'] ?? 'listening').toString(),
        );
      },
      binding: LearningBinding(),
    ),
    GetPage(
      name: AppRoutes.learningLessonDetail,
      page: () =>
          LearningLessonDetailScreen(lessonId: _getLessonIdArg(Get.arguments)),
      binding: LearningBinding(),
    ),
    GetPage(
      name: AppRoutes.grammar,
      page: () => const GrammarScreen(),
      binding: GrammarBinding(),
    ),
    GetPage(
      name: AppRoutes.grammarLessonDetail,
      page: () =>
          GrammarLessonDetailScreen(lessonId: _getLessonIdArg(Get.arguments)),
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
    GetPage(name: AppRoutes.ipa, page: () => const IpaScreen()),
    GetPage(
      name: AppRoutes.progress,
      page: () => const ProgressScreen(),
      binding: ProgressBinding(),
    ),
    GetPage(
      name: AppRoutes.exercise,
      page: () => const ExerciseScreen(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.exerciseQuiz,
      page: () => const ExerciseQuizScreen(),
    ),
    GetPage(
      name: AppRoutes.exerciseResult,
      page: () => const ExerciseResultScreen(),
    ),
    GetPage(
      name: AppRoutes.test,
      page: () => const TestHomeScreen(),
      binding: TestBinding(),
    ),
    GetPage(
      name: AppRoutes.testQuestion,
      page: () => const TestQuestionScreen(),
    ),
    GetPage(name: AppRoutes.testResult, page: () => const TestResultScreen()),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    // Legacy aliases → redirect to VocabHub
    GetPage(
      name: AppRoutes.vocabulary,
      page: () => const VocabTopicListScreen(),
      binding: VocabHubBinding(),
    ),
    GetPage(
      name: AppRoutes.vocabularyList,
      page: () => const VocabWordListScreen(),
    ),
    GetPage(
      name: AppRoutes.spellingPractice,
      page: () => const VocabSpellingScreen(),
    ),
    GetPage(
      name: AppRoutes.spellingResult,
      page: () => const VocabSpellingResultScreen(),
    ),
    // New VocabHub routes
    GetPage(
      name: AppRoutes.vocabWordList,
      page: () => const VocabWordListScreen(),
    ),
    GetPage(
      name: AppRoutes.vocabSpelling,
      page: () => const VocabSpellingScreen(),
    ),
    GetPage(
      name: AppRoutes.vocabSpellingResult,
      page: () => const VocabSpellingResultScreen(),
    ),
  ];
}
