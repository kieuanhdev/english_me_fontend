import 'package:get/get.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';

class ProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressController>(
      () => ProgressController(ProgressRepository()),
    );
  }
}
