import 'package:dio/dio.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/grammar/models/grammar_models.dart';
import 'package:englishme/modules/grammar/repositories/grammar_repository.dart';
import 'package:get/get.dart';

class GrammarController extends GetxController {
  GrammarController(this._repository);

  final GrammarRepository _repository;

  final topics = <GrammarTopic>[].obs;
  final lessons = <GrammarLessonListItem>[].obs;
  final selectedTopic = Rxn<GrammarTopic>();
  final isLoadingTopics = false.obs;
  final isLoadingLessons = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      isLoadingTopics.value = true;
      error.value = '';
      final data = await _repository.getTopics();
      topics.assignAll(data..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
      if (topics.isNotEmpty) {
        await selectTopic(topics.first);
      } else {
        lessons.clear();
      }
    } on DioException catch (e) {
      error.value = e.message ?? T.errorLoadGrammar.tr;
    } finally {
      isLoadingTopics.value = false;
    }
  }

  Future<void> selectTopic(GrammarTopic topic) async {
    if (selectedTopic.value?.id == topic.id) return;
    selectedTopic.value = topic;
    await loadLessons(topic.id);
  }

  Future<void> loadLessons(String topicId) async {
    try {
      isLoadingLessons.value = true;
      error.value = '';
      lessons.clear();
      final data = await _repository.getLessonsByTopic(topicId);
      lessons.assignAll(data..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
    } on DioException catch (e) {
      error.value = e.message ?? T.errorLoadGrammarLessons.tr;
      lessons.clear();
    } catch (_) {
      error.value = T.errorInvalidGrammarData.tr;
      lessons.clear();
    } finally {
      isLoadingLessons.value = false;
    }
  }
}
