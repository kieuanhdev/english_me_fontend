import 'package:get/get.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';

class FlashcardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlashcardController>(() => FlashcardController());
  }
}
