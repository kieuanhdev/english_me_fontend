import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/pronunciation/controllers/pronunciation_controller.dart';
import 'package:englishme/modules/pronunciation/repositories/pronunciation_repository.dart';
import 'package:get/get.dart';

class PronunciationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PronunciationRepository>()) {
      Get.lazyPut<PronunciationRepository>(() => PronunciationRepository(DioClient.instance));
    }
    if (!Get.isRegistered<PronunciationController>()) {
      Get.lazyPut<PronunciationController>(
        () => PronunciationController(Get.find<PronunciationRepository>()),
      );
    }
  }
}
