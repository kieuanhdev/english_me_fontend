import 'package:dio/dio.dart';
import 'package:englishme/data/models/grammar_models.dart';

class GrammarRepository {
  GrammarRepository(this._dio);

  final Dio _dio;

  Future<List<GrammarTopic>> getTopics() async {
    final response = await _dio.get('/grammar/topics');
    final list = (response.data as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => GrammarTopic.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<GrammarLessonListItem>> getLessonsByTopic(String topicId) async {
    final response = await _dio.get('/grammar/topics/$topicId/lessons');
    final list = (response.data as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => GrammarLessonListItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<GrammarLessonDetail> getLessonDetail(String lessonId) async {
    final response = await _dio.get('/grammar/lessons/$lessonId');
    return GrammarLessonDetail.fromJson(
      (response.data as Map).cast<String, dynamic>(),
    );
  }
}
