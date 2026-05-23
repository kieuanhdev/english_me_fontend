import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/learn/controllers/learning_controller.dart';
import 'package:englishme/modules/learn/repositories/learning_repository.dart';

class LearningBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LearningRepository>()) {
      Get.lazyPut<LearningRepository>(
        () => LearningRepository(DioClient.instance),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LearningController>()) {
      Get.lazyPut<LearningController>(
        () => LearningController(Get.find<LearningRepository>()),
        fenix: true,
      );
    }
  }
}
