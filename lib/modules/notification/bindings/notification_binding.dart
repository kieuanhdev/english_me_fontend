import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/notification/controllers/notification_controller.dart';
import 'package:englishme/modules/notification/repositories/notification_repository.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(DioClient.instance),
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationRepository>()),
    );
  }
}
