import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/data/repositories/placement_test_repository.dart';
import 'package:englishme/modules/placement_test/controllers/placement_test_controller.dart';
import 'package:get/get.dart';

class PlacementTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlacementTestRepository>(
      () => PlacementTestRepository(DioClient.instance),
      fenix: true,
    );
    Get.lazyPut<PlacementTestController>(
      () => PlacementTestController(Get.find()),
      fenix: true,
    );
  }
}
