import 'package:dio/dio.dart';

import 'package:englishme/modules/test/models/test_model.dart';

class TestRepository {
  final Dio _dio;
  TestRepository(this._dio);

  Future<TestSession> getTestSession({
    required TestTopic topic,
    required TestLevel level,
  }) async {
    final response = await _dio.post(
      '/tests/sessions',
      data: {'topic': topic.name, 'level': level.name},
    );
    return TestSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TestSubmitResponse> submitTest({
    required String sessionId,
    required List<Map<String, String>> answers,
    required int timeTakenSeconds,
  }) async {
    final response = await _dio.post(
      '/tests/sessions/$sessionId/submit',
      data: {
        'answers': answers,
        'timeTakenSeconds': timeTakenSeconds,
      },
    );
    return TestSubmitResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TestHistoryEntry>> getTestHistory() async {
    final response = await _dio.get('/tests/history');
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(TestHistoryEntry.fromJson)
        .toList();
  }
}
