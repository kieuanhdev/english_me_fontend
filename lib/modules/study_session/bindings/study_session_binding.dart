import 'package:get/get.dart';

// StudySessionController được tạo thủ công trong FlashcardController.onStartStudy()
// vì cần truyền deskId + deskTitle — không dùng binding tự động.
class StudySessionBinding extends Bindings {
  @override
  void dependencies() {}
}
