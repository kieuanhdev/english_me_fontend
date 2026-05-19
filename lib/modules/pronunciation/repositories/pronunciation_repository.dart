import 'dart:io';

import 'package:dio/dio.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';

class PronunciationRepository {
  PronunciationRepository(this._dio);

  final Dio _dio;

  Future<List<PronunciationExercise>> getExercises() async {
    final response = await _dio.get('/pronunciation/exercises');
    final body = response.data;

    List<dynamic> list;

    if (body is List) {
      list = body;
    } else if (body is Map<String, dynamic>) {
      list = (body['exercises'] as List<dynamic>?) ??
          (body['data'] as List<dynamic>?) ??
          [];
    } else {
      return [];
    }

    return list
        .map((e) => PronunciationExercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PronunciationFeedback> assessPronunciation({
    required File audioFile,
    required String exerciseId,
    required String expectedText,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFile.path, filename: 'recording.m4a'),
      'exerciseId': exerciseId,
      'expectedText': expectedText,
    });

    final response = await _dio.post('/pronunciation/assess', data: formData);
    if (response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid response format from assess endpoint',
      );
    }
    return PronunciationFeedback.fromJson(response.data as Map<String, dynamic>);
  }
}
