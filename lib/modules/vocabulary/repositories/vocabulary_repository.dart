import 'package:dio/dio.dart';

import 'package:englishme/modules/vocabulary/models/vocabulary_model.dart';

class VocabularyRepository {
  final Dio _dio;
  VocabularyRepository(this._dio);

  Future<List<VocabularyTopic>> getTopics() async {
    final response = await _dio.get('/vocabulary/topics');
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(VocabularyTopic.fromJson)
        .toList();
  }

  Future<List<VocabularyWord>> getWordsByTopic(String topicId) async {
    final response = await _dio.get('/vocabulary/topics/$topicId/words');
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => VocabularyWord.fromJson(json, topicId: topicId))
        .toList();
  }
}
