import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:englishme/modules/learn/models/learning_models.dart';

class LearningRepository {
  LearningRepository(this._dio);

  final Dio _dio;

  Future<LearningHub> getHub({String? level}) async {
    final response = await _dio.get(
      '/learning/hub',
      queryParameters: level == null ? null : {'level': level},
    );
    return LearningHub.fromJson(_asMap(response.data));
  }

  Future<LearningSkillLessons> getSkillLessons({
    required String level,
    required String skill,
  }) async {
    final response = await _dio.get(
      '/learning/levels/$level/skills/$skill/lessons',
    );
    return LearningSkillLessons.fromJson(_asMap(response.data));
  }

  Future<LearningPathDetail> getPathDetail({
    required String level,
    required String pathId,
  }) async {
    final response = await _dio.get('/learning/paths/$pathId');
    return LearningPathDetail.fromJson(_asMap(response.data));
  }

  Future<LearningLessonDetail> getLessonDetail(String lessonId) async {
    _log('Loading lesson detail: lessonId=$lessonId');
    final response = await _dio.get('/learning/lessons/$lessonId');
    final data = _asMap(response.data);
    _log('Lesson detail response keys: ${data.keys.toList()}');
    try {
      final lesson = LearningLessonDetail.fromJson(data);
      _log(
        'Parsed lesson detail: id=${lesson.id}, '
        'title=${lesson.title}, activities=${lesson.activities.length}',
      );
      return lesson;
    } catch (error, stackTrace) {
      _log('Failed to parse lesson detail: $error');
      _log('Raw lesson detail data: $data');
      _log('$stackTrace');
      rethrow;
    }
  }

  Future<LearningCompleteResponse> completeLesson({
    required String lessonId,
    required int score,
    required int timeSpentSeconds,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _dio.post(
      '/learning/lessons/$lessonId/complete',
      data: {
        'score': score,
        'timeSpentSeconds': timeSpentSeconds,
        'answers': answers,
      },
    );
    return LearningCompleteResponse.fromJson(_asMap(response.data));
  }
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  _log('Expected Map<String, dynamic> but got ${data.runtimeType}: $data');
  return const {};
}

void _log(String message) {
  if (kDebugMode) {
    debugPrint('[LearningRepository] $message');
  }
}
