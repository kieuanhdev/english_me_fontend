import 'package:get/get.dart';

import 'package:englishme/modules/weak_skills/bindings/weak_skills_binding.dart';
import 'package:englishme/modules/weak_skills/views/weak_skills_screen.dart';
import 'package:englishme/routes/app_routes.dart';

abstract class WeakSkillsPages {
  static final pages = [
    GetPage(
      name: AppRoutes.weakSkills,
      page: () => const WeakSkillsScreen(),
      binding: WeakSkillsBinding(),
    ),
  ];
}
