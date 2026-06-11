import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/auth/repositories/user_repository.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_deck_controller.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';

class VocabHubBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabDeckRepository>()) {
      Get.lazyPut<VocabDeckRepository>(() => VocabDeckRepository(DioClient.instance));
    }
    if (!Get.isRegistered<StudySessionRepository>()) {
      Get.lazyPut<StudySessionRepository>(() => StudySessionRepository(DioClient.instance));
    }
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(() => UserRepository(DioClient.instance));
    }
    Get.lazyPut<VocabDeckController>(
      () => VocabDeckController(
        Get.find<VocabDeckRepository>(),
        Get.find<StudySessionRepository>(),
        Get.find<UserRepository>(),
      ),
    );
  }
}
