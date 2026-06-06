import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_deck_controller.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';

class VocabHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabDeckRepository>(() => VocabDeckRepository(DioClient.instance));
    Get.lazyPut<VocabDeckController>(() => VocabDeckController());
  }
}
