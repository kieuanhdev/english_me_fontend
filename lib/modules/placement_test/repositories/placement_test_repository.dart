import 'package:dio/dio.dart';
import 'package:englishme/modules/placement_test/models/placement_test_models.dart';

class PlacementTestRepository {
  final Dio _dio;
  PlacementTestRepository(this._dio);

  Future<StartTestResponse> startTest() async {
    final response = await _dio.post('/placement-test/start');
    return StartTestResponse.fromJson(_asMap(response.data));
  }

  Future<CatAnswerResponseModel> answerQuestion(
    String sessionId,
    String questionId,
    String selectedAnswer,
  ) async {
    final response = await _dio.post(
      '/placement-test/$sessionId/answer',
      data: {'questionId': questionId, 'selectedAnswer': selectedAnswer},
    );
    return CatAnswerResponseModel.fromJson(_asMap(response.data));
  }

  Future<TestResultModel> completeTest(String sessionId) async {
    final response = await _dio.post('/placement-test/$sessionId/complete');
    return TestResultModel.fromJson(_asMap(response.data));
  }

  /// Ép response.data về Map an toàn; trả map rỗng nếu backend trả null/sai kiểu.
  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};

  /// Tự chọn trình độ CEFR mà không làm bài kiểm tra.
  /// Backend set cefrLevel + onboarded, trả về user đã cập nhật.
  Future<void> selfSelectLevel(String level) async {
    await _dio.post(
      '/placement-test/self-select',
      data: {'level': level},
    );
  }
}
