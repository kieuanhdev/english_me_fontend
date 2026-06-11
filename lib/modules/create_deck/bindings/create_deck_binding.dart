import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/modules/create_deck/controllers/create_deck_controller.dart';

class CreateDeckBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabDeckRepository>()) {
      Get.lazyPut<VocabDeckRepository>(() => VocabDeckRepository(DioClient.instance));
    }
    final args = Get.arguments;
    final editing = args is VocabDeck ? args : null;
    Get.lazyPut<CreateDeckController>(
      () => CreateDeckController(
        editingDeck: editing,
        repo: Get.find<VocabDeckRepository>(),
      ),
    );
  }
}
