import 'package:dio/dio.dart';

import 'package:englishme/modules/writing/models/writing_models.dart';

/// Gọi backend luyện Viết theo đề với AI. Stateless: FE giữ promptId + đề.
class WritingRepository {
  WritingRepository(this._dio);
  final Dio _dio;

  /// Sinh đề viết theo CEFR user.
  Future<WritingPrompt> getPrompt({String? level, String? lessonId}) async {
    final response = await _dio.get(
      '/writing/prompt',
      queryParameters: {
        if (level != null && level.isNotEmpty) 'level': level,
        if (lessonId != null && lessonId.isNotEmpty) 'lessonId': lessonId,
      },
    );
    return WritingPrompt.fromJson(response.data as Map<String, dynamic>);
  }

  /// Nộp bài → AI chấm + cộng XP.
  Future<WritingGrade> grade({
    required WritingPrompt prompt,
    required String essay,
  }) async {
    final response = await _dio.post(
      '/writing/grade',
      data: {
        'promptId': prompt.promptId,
        'prompt': prompt.prompt,
        'level': prompt.level,
        'essay': essay,
      },
    );
    return WritingGrade.fromJson(response.data as Map<String, dynamic>);
  }
}
