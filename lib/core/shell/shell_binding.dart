import 'package:englishme/core/shell/shell_controller.dart';
import 'package:get/get.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShellController(), permanent: true);
  }
}
