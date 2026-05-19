import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';

class ProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressRepository>(
      () => ProgressRepository(DioClient.instance),
    );
    Get.lazyPut<ProgressController>(
      () => ProgressController(Get.find<ProgressRepository>()),
    );
  }
}
