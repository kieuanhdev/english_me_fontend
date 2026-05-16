import 'package:get/get.dart';
import 'package:englishme/modules/vocabulary/controllers/vocabulary_controller.dart';

class VocabularyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabularyController>(() => VocabularyController());
  }
}
