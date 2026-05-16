import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/modules/exercise/controllers/exercise_controller.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';
import 'package:englishme/modules/test/controllers/test_controller.dart';
import 'package:get/get.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShellController(), permanent: true);
    Get.lazyPut<ExerciseController>(() => ExerciseController());
    Get.lazyPut<TestController>(() => TestController());
    Get.lazyPut<ProgressController>(() => ProgressController(ProgressRepository()));
  }
}
