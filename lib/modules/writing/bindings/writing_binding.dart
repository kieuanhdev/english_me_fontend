import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/writing/controllers/writing_controller.dart';
import 'package:englishme/modules/writing/repositories/writing_repository.dart';

class WritingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WritingRepository>()) {
      Get.lazyPut<WritingRepository>(
          () => WritingRepository(DioClient.instance));
    }
    if (!Get.isRegistered<WritingController>()) {
      Get.lazyPut<WritingController>(
          () => WritingController(Get.find<WritingRepository>()));
    }
  }
}
