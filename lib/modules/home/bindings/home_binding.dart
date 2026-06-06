import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/home/repositories/home_repository.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository(DioClient.instance));
    Get.lazyPut<VocabDeckRepository>(
      () => VocabDeckRepository(DioClient.instance),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<HomeRepository>(),
        Get.find<VocabDeckRepository>(),
      ),
    );
  }
}
