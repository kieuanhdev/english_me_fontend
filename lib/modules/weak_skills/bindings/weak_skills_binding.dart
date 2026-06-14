import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';
import 'package:englishme/modules/pronunciation/repositories/pronunciation_repository.dart';
import 'package:englishme/modules/weak_skills/controllers/weak_skills_controller.dart';

class WeakSkillsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProgressRepository>()) {
      Get.lazyPut<ProgressRepository>(
        () => ProgressRepository(DioClient.instance),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PronunciationRepository>()) {
      Get.lazyPut<PronunciationRepository>(
        () => PronunciationRepository(DioClient.instance),
        fenix: true,
      );
    }
    Get.lazyPut<WeakSkillsController>(
      () => WeakSkillsController(
        Get.find<ProgressRepository>(),
        Get.find<PronunciationRepository>(),
      ),
    );
  }
}
