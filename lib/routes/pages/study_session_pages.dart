import 'package:englishme/modules/study_session/bindings/study_session_binding.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_card_back_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_front_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class StudySessionPages {
  static final pages = [
    GetPage(
      name: AppRoutes.studySession,
      page: () => const StudySessionFrontScreen(),
      binding: StudySessionBinding(),
    ),
    GetPage(
      name: AppRoutes.studySessionCardBack,
      page: () => const StudySessionCardBackScreen(),
    ),
    GetPage(
      name: AppRoutes.sessionSummary,
      page: () => const SessionSummaryScreen(),
    ),
  ];
}
