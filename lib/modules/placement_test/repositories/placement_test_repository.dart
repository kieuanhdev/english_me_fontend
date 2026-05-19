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
}
