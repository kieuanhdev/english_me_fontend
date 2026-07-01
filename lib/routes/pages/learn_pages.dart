import 'package:englishme/modules/grammar/bindings/grammar_binding.dart';
import 'package:englishme/modules/grammar/bindings/grammar_theory_binding.dart';
import 'package:englishme/modules/grammar/views/grammar_lesson_detail_screen.dart';
import 'package:englishme/modules/grammar/views/grammar_theory_screen.dart';
import 'package:englishme/modules/dictation/bindings/dictation_binding.dart';
import 'package:englishme/modules/dictation/views/dictation_screen.dart';
import 'package:englishme/modules/writing/bindings/writing_binding.dart';
import 'package:englishme/modules/writing/views/writing_screen.dart';
import 'package:englishme/modules/learn/bindings/curriculum_binding.dart';
import 'package:englishme/modules/learn/views/checkpoint_screen.dart';
import 'package:englishme/modules/learn/views/lesson_player_screen.dart';
import 'package:englishme/modules/learn/views/unit_detail_screen.dart';
import 'package:englishme/modules/learn/views/unit_list_screen.dart';
import 'package:englishme/routes/app_route_args.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class LearnPages {
  static final pages = [
    GetPage(
      name: AppRoutes.learn,
      page: () => const UnitListScreen(),
      binding: CurriculumBinding(),
    ),
    GetPage(
      name: AppRoutes.curriculumUnits,
      page: () => const UnitListScreen(),
      binding: CurriculumBinding(),
    ),
    GetPage(
      name: AppRoutes.curriculumUnitDetail,
      page: () => const UnitDetailScreen(),
      binding: CurriculumBinding(),
    ),
    GetPage(
      name: AppRoutes.curriculumLessonPlayer,
      page: () => const LessonPlayerScreen(),
      binding: CurriculumBinding(),
    ),
    GetPage(
      name: AppRoutes.curriculumCheckpoint,
      page: () => const CheckpointScreen(),
      binding: CurriculumBinding(),
    ),
    GetPage(
      name: AppRoutes.grammarTheory,
      page: () => const GrammarTheoryScreen(),
      binding: GrammarTheoryBinding(),
    ),
    GetPage(
      name: AppRoutes.grammarLessonDetail,
      page: () => GrammarLessonDetailScreen(
        lessonId: AppRouteArgs.lessonId(Get.arguments),
        showExercises: AppRouteArgs.showExercises(Get.arguments),
      ),
      binding: GrammarBinding(),
    ),
    // 4 kỹ năng: Nghe→dictation, Đọc→exercise, Viết→writing (chat AI).
    GetPage(
      name: AppRoutes.dictation,
      page: () => const DictationScreen(),
      binding: DictationBinding(),
    ),
    GetPage(
      name: AppRoutes.writing,
      page: () => const WritingScreen(),
      binding: WritingBinding(),
    ),
  ];
}
