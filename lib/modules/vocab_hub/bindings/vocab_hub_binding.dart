import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_desk_controller.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_topic_controller.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_desk_repository.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_topic_repository.dart';

class VocabHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabTopicRepository>(() => VocabTopicRepository(DioClient.instance));
    Get.lazyPut<VocabDeskRepository>(() => VocabDeskRepository(DioClient.instance));
    Get.lazyPut<VocabTopicController>(() => VocabTopicController(Get.find()));
    Get.lazyPut<VocabDeskController>(() => VocabDeskController());
  }
}
