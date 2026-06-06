import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';
import 'package:englishme/modules/learn/repositories/api_curriculum_repository.dart';
import 'package:englishme/modules/learn/controllers/unit_list_controller.dart';
import 'package:englishme/modules/learn/controllers/unit_detail_controller.dart';
import 'package:englishme/modules/learn/controllers/lesson_player_controller.dart';
import 'package:englishme/modules/learn/controllers/checkpoint_controller.dart';

class CurriculumBinding extends Bindings {
  @override
  void dependencies() {
    // API thật. Đổi lại MockCurriculumRepository() nếu cần chạy offline để test UI.
    Get.lazyPut<CurriculumRepository>(
      () => ApiCurriculumRepository(DioClient.instance),
      fenix: true,
    );

    Get.lazyPut(() => UnitListController(Get.find()), fenix: true);
    Get.lazyPut(() => UnitDetailController(Get.find()), fenix: true);
    Get.lazyPut(() => LessonPlayerController(Get.find()), fenix: true);
    Get.lazyPut(() => CheckpointController(Get.find()), fenix: true);
  }
}
