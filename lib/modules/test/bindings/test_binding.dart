import 'package:get/get.dart';
import 'package:englishme/modules/test/controllers/test_controller.dart';

class TestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestController>(() => TestController());
  }
}
