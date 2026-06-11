import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/modules/auth/repositories/user_repository.dart';
import 'package:englishme/modules/notification/controllers/notification_controller.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/profile/repositories/profile_repository.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    ShellController.ensureRegistered();
    // Warm controller thông báo (permanent) → badge chuông populate ngay khi
    // vào shell, hiển thị nhất quán ở mọi màn dùng AppMainAppBar.
    NotificationController.ensureRegistered();
    Get.lazyPut<UserRepository>(() => UserRepository(DioClient.instance));
    Get.lazyPut<ProgressRepository>(
      () => ProgressRepository(DioClient.instance),
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(userRepo: Get.find<UserRepository>()),
    );
    Get.lazyPut<ProgressController>(
      () => ProgressController(Get.find<ProgressRepository>()),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileRepository>(),
        Get.find<ProgressRepository>(),
      ),
    );
  }
}
