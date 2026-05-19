import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/vocabulary/controllers/vocabulary_controller.dart';
import 'package:englishme/modules/vocabulary/repositories/vocabulary_repository.dart';

class VocabularyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabularyRepository>(
      () => VocabularyRepository(DioClient.instance),
    );
    Get.lazyPut<VocabularyController>(
      () => VocabularyController(Get.find<VocabularyRepository>()),
    );
  }
}
