import 'package:get/get.dart';

import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/modules/learn/repositories/learning_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum LearningHubState { idle, loading, loaded, error }

class LearningController extends GetxController {
  LearningController(this._repo);

  final LearningRepository _repo;

  final hubState = LearningHubState.idle.obs;
  final errorMessage = ''.obs;
  final hub = Rxn<LearningHub>();
  final selectedLevel = 'A1'.obs;

  @override
  void onInit() {
    super.onInit();
    loadHub();
  }

  Future<void> loadHub({String? level}) async {
    hubState.value = LearningHubState.loading;
    errorMessage.value = '';
    try {
      final result = await _repo.getHub(level: level);
      hub.value = result;
      selectedLevel.value = result.selectedLevel;
      hubState.value = LearningHubState.loaded;
    } catch (_) {
      errorMessage.value = 'Không tải được lộ trình học tập.';
      hubState.value = LearningHubState.error;
    }
  }

  Future<void> selectLevel(String level) async {
    selectedLevel.value = level;
    await loadHub(level: level);
  }

  void openPath(LearningPath path) {
    if (path.isLocked) return;
    Get.toNamed(
      AppRoutes.learningPathDetail,
      arguments: {'level': selectedLevel.value, 'pathId': path.id},
    );
  }

  void openSkill(LearningSkillTrack skill) {
    if (!skill.enabled) return;
    Get.toNamed(
      AppRoutes.learningSkillLessons,
      arguments: {'level': selectedLevel.value, 'skill': skill.type},
    );
  }

  void openSupport(LearningSupportTrack track) {
    if (!track.enabled) return;
    switch (track.type) {
      case 'grammar':
        Get.toNamed(
          AppRoutes.grammar,
          arguments: {'level': selectedLevel.value},
        );
        return;
      case 'vocabulary':
        Get.toNamed(
          AppRoutes.vocabulary,
          arguments: {'level': selectedLevel.value},
        );
        return;
      case 'flashcard':
        Get.toNamed(
          AppRoutes.flashcards,
          arguments: {'level': selectedLevel.value},
        );
        return;
      case 'test':
        Get.toNamed(AppRoutes.test);
        return;
    }
    if (track.route.isEmpty) return;
    Get.toNamed(track.route, arguments: {'level': selectedLevel.value});
  }
}
