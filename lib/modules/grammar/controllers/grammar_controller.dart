import 'package:dio/dio.dart';
import 'package:englishme/data/models/grammar_models.dart';
import 'package:englishme/data/repositories/grammar_repository.dart';
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
      error.value = e.message ?? 'Không tải được chủ đề ngữ pháp';
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
      error.value = e.message ?? 'Không tải được danh sách bài học';
      lessons.clear();
    } catch (_) {
      error.value = 'Dữ liệu bài học không hợp lệ. Vui lòng thử lại.';
      lessons.clear();
    } finally {
      isLoadingLessons.value = false;
    }
  }
}
