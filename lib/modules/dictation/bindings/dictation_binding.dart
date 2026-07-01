import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/dictation/controllers/dictation_controller.dart';
import 'package:englishme/modules/dictation/repositories/dictation_repository.dart';

class DictationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DictationRepository>()) {
      Get.lazyPut<DictationRepository>(
          () => DictationRepository(DioClient.instance));
    }
    if (!Get.isRegistered<DictationController>()) {
      Get.lazyPut<DictationController>(
          () => DictationController(Get.find<DictationRepository>()));
    }
  }
}
