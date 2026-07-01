import 'package:dio/dio.dart';

import 'package:englishme/modules/dictation/models/dictation_models.dart';

class DictationRepository {
  final Dio _dio;
  DictationRepository(this._dio);

  Future<DictationSession> getSession({String? level, int size = 5, String? lessonId}) async {
    final response = await _dio.get(
      '/dictation/sessions',
      queryParameters: {
        'size': size,
        if (level != null && level.isNotEmpty) 'level': level,
        if (lessonId != null && lessonId.isNotEmpty) 'lessonId': lessonId,
      },
    );
    return DictationSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DictationCompleteResult> complete({
    required String sessionId,
    required int correct,
    required int total,
  }) async {
    final response = await _dio.post(
      '/dictation/sessions/complete',
      data: {'sessionId': sessionId, 'correct': correct, 'total': total},
    );
    return DictationCompleteResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
