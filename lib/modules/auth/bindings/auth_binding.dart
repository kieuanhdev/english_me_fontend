import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/services/auth_service.dart';
import 'package:englishme/data/repositories/auth_repository.dart';
import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<AuthRepository>(() => AuthRepository(DioClient.instance));
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find(), Get.find()),
    );
  }
}
