import 'package:get/get.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/modules/create_desk/controllers/create_desk_controller.dart';

class CreateDeskBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final editing = args is VocabDesk ? args : null;
    Get.lazyPut<CreateDeskController>(() => CreateDeskController(editingDesk: editing));
  }
}
