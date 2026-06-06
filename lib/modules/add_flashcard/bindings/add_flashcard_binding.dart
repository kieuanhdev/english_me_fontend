import 'package:get/get.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';

class AddFlashcardBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    if (args is VocabDeck) {
      Get.lazyPut<AddFlashcardController>(() => AddFlashcardController(deck: args));
      return;
    }
    if (args is AddFlashcardArgs) {
      Get.lazyPut<AddFlashcardController>(
        () => AddFlashcardController(
          deck: args.deck,
          editCard: args.editCard,
        ),
      );
    }
  }
}
