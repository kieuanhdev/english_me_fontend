import 'package:englishme/modules/pronunciation/controllers/pronunciation_controller.dart';
import 'package:get/get.dart';

class PronunciationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PronunciationController>(() => PronunciationController());
  }
}
