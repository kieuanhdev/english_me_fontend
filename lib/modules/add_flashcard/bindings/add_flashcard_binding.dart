import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';

class AddFlashcardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabDeckRepository>()) {
      Get.lazyPut<VocabDeckRepository>(() => VocabDeckRepository(DioClient.instance));
    }
    final args = Get.arguments;
    if (args is VocabDeck) {
      Get.lazyPut<AddFlashcardController>(
        () => AddFlashcardController(
          deck: args,
          repo: Get.find<VocabDeckRepository>(),
        ),
      );
      return;
    }
    if (args is AddFlashcardArgs) {
      Get.lazyPut<AddFlashcardController>(
        () => AddFlashcardController(
          deck: args.deck,
          editCard: args.editCard,
          repo: Get.find<VocabDeckRepository>(),
        ),
      );
    }
  }
}
