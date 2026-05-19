import 'package:dio/dio.dart';

import 'package:englishme/modules/exercise/models/exercise_model.dart';

class ExerciseRepository {
  final Dio _dio;
  ExerciseRepository(this._dio);

  Future<ExerciseSession> getExerciseSession({
    required ExerciseCategory category,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/exercises/sessions',
      queryParameters: {'category': category.name, 'size': size},
    );
    return ExerciseSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ExerciseCompleteResponse> completeSession({
    required String sessionId,
    required List<Map<String, String>> answers,
  }) async {
    final response = await _dio.post(
      '/exercises/sessions/$sessionId/complete',
      data: {'answers': answers},
    );
    return ExerciseCompleteResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
