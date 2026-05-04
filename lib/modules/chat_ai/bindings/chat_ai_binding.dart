import 'package:englishme/modules/chat_ai/controllers/chat_ai_controller.dart';
import 'package:get/get.dart';

class ChatAiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatAiController>(() => ChatAiController());
  }
}
