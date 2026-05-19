import 'package:get/get.dart';
import 'package:englishme/modules/flashcard/models/desk_model.dart';
import 'package:englishme/modules/deck_prep/controllers/deck_prep_controller.dart';

class DeckPrepBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    if (args is DeskModel) {
      Get.lazyPut<DeckPrepController>(() => DeckPrepController(desk: args));
    }
  }
}
