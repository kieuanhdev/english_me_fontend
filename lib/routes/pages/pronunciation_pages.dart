import 'package:englishme/modules/pronunciation/bindings/pronunciation_binding.dart';
import 'package:englishme/modules/pronunciation/views/ipa_screen.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_insight_screen.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_result_screen.dart';
import 'package:englishme/modules/pronunciation/views/pronunciation_screen.dart';
import 'package:englishme/modules/pronunciation/views/speaking_choice_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class PronunciationPages {
  static final pages = [
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
      binding: PronunciationBinding(),
    ),
    GetPage(name: AppRoutes.ipa, page: () => const IpaScreen()),
    GetPage(
      name: AppRoutes.pronunciationInsight,
      page: () => const PronunciationInsightScreen(),
    ),
  ];
}
