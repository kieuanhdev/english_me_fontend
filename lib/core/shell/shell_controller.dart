import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

class ShellController extends GetxController {
  final currentTab = 0.obs;

  void switchTab(int index) => currentTab.value = index;

  /// Dùng cho sub-screen khi chuyển tab qua bottom nav.
  static void goToTab(int index) {
    Get.find<ShellController>().switchTab(index);
    Get.offAllNamed(AppRoutes.shell);
  }
}
