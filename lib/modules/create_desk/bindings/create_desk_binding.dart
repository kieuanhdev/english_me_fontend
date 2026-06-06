import 'package:get/get.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/create_desk/controllers/create_desk_controller.dart';

class CreateDeskBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final editing = args is VocabDeck ? args : null;
    Get.lazyPut<CreateDeskController>(() => CreateDeskController(editingDeck: editing));
  }
}
