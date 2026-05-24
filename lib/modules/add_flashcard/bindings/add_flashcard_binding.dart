import 'package:get/get.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';

class AddFlashcardBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    if (args is VocabDesk) {
      Get.lazyPut<AddFlashcardController>(() => AddFlashcardController(desk: args));
      return;
    }
    if (args is AddFlashcardArgs) {
      Get.lazyPut<AddFlashcardController>(
        () => AddFlashcardController(
          desk: args.desk,
          editCard: args.editCard,
        ),
      );
    }
  }
}
