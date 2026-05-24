import 'package:dio/dio.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_topic_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';

class VocabTopicRepository {
  final Dio _dio;
  VocabTopicRepository(this._dio);

  Future<List<VocabTopic>> getTopics() async {
    final response = await _dio.get('/vocabulary/topics');
    final data = response.data;
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(VocabTopic.fromJson).toList();
  }

  Future<List<VocabWord>> getWordsByTopic(String topicId) async {
    final response = await _dio.get('/vocabulary/topics/$topicId/words');
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => VocabWord.fromTopicJson(json, topicId: topicId))
        .toList();
  }
}
