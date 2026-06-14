import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/routes/pages/auth_pages.dart';
import 'package:englishme/routes/pages/conversation_pages.dart';
import 'package:englishme/routes/pages/core_pages.dart';
import 'package:englishme/routes/pages/exercise_pages.dart';
import 'package:englishme/routes/pages/flashcard_pages.dart';
import 'package:englishme/routes/pages/learn_pages.dart';
import 'package:englishme/routes/pages/placement_test_pages.dart';
import 'package:englishme/routes/pages/profile_pages.dart';
import 'package:englishme/routes/pages/progress_pages.dart';
import 'package:englishme/routes/pages/pronunciation_pages.dart';
import 'package:englishme/routes/pages/study_session_pages.dart';
import 'package:englishme/routes/pages/test_pages.dart';
import 'package:englishme/routes/pages/weak_skills_pages.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final pages = [
    ...CorePages.pages,
    ...AuthPages.pages,
    ...LearnPages.pages,
    ...FlashcardPages.pages,
    ...PlacementTestPages.pages,
    ...StudySessionPages.pages,
    ...PronunciationPages.pages,
    ...ConversationPages.pages,
    ...ExercisePages.pages,
    ...TestPages.pages,
    ...ProgressPages.pages,
    ...ProfilePages.pages,
    ...WeakSkillsPages.pages,
  ];
}
