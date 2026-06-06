import 'package:dio/dio.dart';
import 'package:englishme/modules/placement_test/models/placement_test_models.dart';

class PlacementTestRepository {
  final Dio _dio;
  PlacementTestRepository(this._dio);

  Future<StartTestResponse> startTest() async {
    final response = await _dio.post('/placement-test/start');
    return StartTestResponse.fromJson(response.data);
  }

  Future<AnswerResponseModel> answerQuestion(
    String sessionId,
    String questionId,
    String selectedAnswer,
  ) async {
    final response = await _dio.post(
      '/placement-test/$sessionId/answer',
      data: {'questionId': questionId, 'selectedAnswer': selectedAnswer},
    );
    return AnswerResponseModel.fromJson(response.data);
  }

  Future<TestResultModel> completeTest(String sessionId) async {
    final response = await _dio.post('/placement-test/$sessionId/complete');
    return TestResultModel.fromJson(response.data);
  }

  /// Tự chọn trình độ CEFR mà không làm bài kiểm tra.
  /// Backend set cefrLevel + onboarded, trả về user đã cập nhật.
  Future<void> selfSelectLevel(String level) async {
    await _dio.post(
      '/placement-test/self-select',
      data: {'level': level},
    );
  }
}
