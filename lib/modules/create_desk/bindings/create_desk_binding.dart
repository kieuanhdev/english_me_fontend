import 'package:get/get.dart';
import 'package:englishme/modules/create_desk/controllers/create_desk_controller.dart';

class CreateDeskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateDeskController>(() => CreateDeskController());
  }
}
