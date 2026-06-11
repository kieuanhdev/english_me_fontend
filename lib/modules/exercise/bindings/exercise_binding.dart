import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/exercise/controllers/exercise_controller.dart';
import 'package:englishme/modules/exercise/repositories/exercise_repository.dart';

class ExerciseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ExerciseRepository>()) {
      Get.lazyPut<ExerciseRepository>(() => ExerciseRepository(DioClient.instance));
    }
    if (!Get.isRegistered<ExerciseController>()) {
      Get.lazyPut<ExerciseController>(() => ExerciseController(Get.find<ExerciseRepository>()));
    }
  }
}
