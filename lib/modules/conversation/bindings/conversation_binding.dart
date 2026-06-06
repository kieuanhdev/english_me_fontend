import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/modules/conversation/controllers/conversation_controller.dart';
import 'package:get/get.dart';

class ConversationBinding extends Bindings {
  @override
  void dependencies() {
    // TtsService đã đăng ký global ở main.dart; phòng hờ nếu chưa có.
    if (!Get.isRegistered<TtsService>()) {
      Get.put(TtsService(), permanent: true);
    }
    Get.lazyPut<ConversationController>(() => ConversationController());
  }
}
