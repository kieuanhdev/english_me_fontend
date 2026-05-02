import 'package:dio/dio.dart';
import 'package:englishme/data/models/placement_test_models.dart';

class PlacementTestRepository {
  final Dio _dio;
  PlacementTestRepository(this._dio);

  Future<StartTestResponse> startTest(String idToken) async {
    final response = await _dio.post(
      '/placement-test/start',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return StartTestResponse.fromJson(response.data);
  }

  Future<AnswerResponseModel> answerQuestion(
    String sessionId,
    String idToken,
    String questionId,
    String selectedAnswer,
  ) async {
    final response = await _dio.post(
      '/placement-test/$sessionId/answer',
      data: {'questionId': questionId, 'selectedAnswer': selectedAnswer},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return AnswerResponseModel.fromJson(response.data);
  }

  Future<TestResultModel> completeTest(String sessionId, String idToken) async {
    final response = await _dio.post(
      '/placement-test/$sessionId/complete',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return TestResultModel.fromJson(response.data);
  }
}
