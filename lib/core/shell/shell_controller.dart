import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

class ShellController extends GetxController {
  final currentTab = 0.obs;

  void switchTab(int index) => currentTab.value = index;

  static ShellController ensureRegistered() {
    if (Get.isRegistered<ShellController>()) {
      return Get.find<ShellController>();
    }
    return Get.put(ShellController(), permanent: true);
  }

  /// Dung cho sub-screen khi chuyen tab qua bottom nav.
  static void goToTab(int index) {
    ensureRegistered().switchTab(index);
    Get.offAllNamed(AppRoutes.shell);
  }
}
