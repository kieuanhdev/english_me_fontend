import 'package:dio/dio.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/grammar/models/grammar_models.dart';
import 'package:englishme/modules/grammar/repositories/grammar_repository.dart';
import 'package:get/get.dart';

class GrammarTheoryController extends GetxController {
  GrammarTheoryController(this._repository);

  final GrammarRepository _repository;

  /// CEFR levels in fixed order — always rendered as tabs even if empty.
  static const cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  final groups = <GrammarLevelGroup>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  /// Index of the tab to open first, derived from the learner's level.
  final initialTabIndex = 0.obs;

  /// Lazily-loaded lessons per topic id, so expanding a topic only fetches once.
  final lessonsByTopic = <String, List<GrammarLessonListItem>>{}.obs;
  final loadingTopicIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _resolveInitialLevel();
    loadGroups();
  }

  void _resolveInitialLevel() {
    final args = Get.arguments;
    String? level;
    if (args is Map && args['level'] != null) {
      level = args['level'].toString();
    } else if (args is String) {
      level = args;
    }
    final idx = cefrLevels.indexOf((level ?? '').trim().toUpperCase());
    initialTabIndex.value = idx < 0 ? 0 : idx;
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _repository.getTopicsByLevel();
      groups.assignAll(data);
    } on DioException catch (e) {
      error.value = e.message ?? T.errorLoadGrammar.tr;
    } catch (_) {
      error.value = T.errorLoadGrammar.tr;
    } finally {
      isLoading.value = false;
    }
  }

  List<GrammarTopic> topicsForLevel(String level) {
    final match = groups.firstWhereOrNull(
      (g) => g.level.toUpperCase() == level.toUpperCase(),
    );
    return match?.topics ?? const [];
  }

  Future<void> loadLessonsForTopic(String topicId) async {
    if (lessonsByTopic.containsKey(topicId) ||
        loadingTopicIds.contains(topicId)) {
      return;
    }
    try {
      loadingTopicIds.add(topicId);
      loadingTopicIds.refresh();
      final data = await _repository.getLessonsByTopic(topicId);
      data.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      lessonsByTopic[topicId] = data;
    } catch (_) {
      lessonsByTopic[topicId] = const [];
    } finally {
      loadingTopicIds.remove(topicId);
      loadingTopicIds.refresh();
    }
  }
}
