import 'package:get/get.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/profile/repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(ProfileRepository()),
    );
  }
}
