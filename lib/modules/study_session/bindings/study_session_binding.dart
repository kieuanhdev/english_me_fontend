import 'package:get/get.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';

class StudySessionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StudySessionController>(StudySessionController());
  }
}
