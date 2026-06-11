import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';
import 'package:englishme/modules/study_session/repositories/study_session_repository.dart';
import 'package:englishme/modules/deck_prep/controllers/deck_prep_controller.dart';

class DeckPrepBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    if (args is VocabDeck) {
      if (!Get.isRegistered<VocabDeckRepository>()) {
        Get.lazyPut<VocabDeckRepository>(() => VocabDeckRepository(DioClient.instance));
      }
      if (!Get.isRegistered<StudySessionRepository>()) {
        Get.lazyPut<StudySessionRepository>(() => StudySessionRepository(DioClient.instance));
      }
      Get.lazyPut<DeckPrepController>(
        () => DeckPrepController(
          deck: args,
          repo: Get.find<VocabDeckRepository>(),
          sessionRepo: Get.find<StudySessionRepository>(),
        ),
      );
    }
  }
}
