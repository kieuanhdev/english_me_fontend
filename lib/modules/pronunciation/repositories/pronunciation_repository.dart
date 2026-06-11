import 'package:dio/dio.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';

class PronunciationRepository {
  PronunciationRepository(this._dio);

  final Dio _dio;

  Future<List<PronunciationExercise>> getExercises({
    String? level,
    String? keyword,
  }) async {
    final response = await _dio.get(
      '/pronunciation/exercises',
      queryParameters: {
        if (level != null && level.isNotEmpty) 'level': level,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );
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

  /// Chấm phát âm dựa trên transcript (text STT) — backend dùng Levenshtein Distance.
  Future<PronunciationFeedback> assessTranscript({
    required String referenceText,
    required String spokenText,
    required String exerciseId,
  }) async {
    final response = await _dio.post(
      '/pronunciation/assess-text',
      data: {
        'referenceText': referenceText,
        'spokenText': spokenText,
        'exerciseId': exerciseId,
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid response format from assess-text endpoint',
      );
    }
    return PronunciationFeedback.fromJson(response.data as Map<String, dynamic>);
  }

  /// Chấm phát âm từ FILE AUDIO thật (đề cương MT4): upload audio lên backend,
  /// backend gọi Google Cloud Speech-to-Text ra transcript rồi chấm Levenshtein.
  ///
  /// Ném [DioException] với status 422 khi STT chưa bật / không nhận ra tiếng nói
  /// — controller bắt mã này để fallback STT on-device.
  Future<PronunciationFeedback> assessAudio({
    required String audioPath,
    required String referenceText,
    required String exerciseId,
  }) async {
    final formData = FormData.fromMap({
      'referenceText': referenceText,
      'exerciseId': exerciseId,
      'audio': await MultipartFile.fromFile(audioPath, filename: 'audio.wav'),
    });
    final response = await _dio.post(
      '/pronunciation/assess-audio',
      data: formData,
    );
    if (response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid response format from assess-audio endpoint',
      );
    }
    return PronunciationFeedback.fromJson(response.data as Map<String, dynamic>);
  }

  /// Insight cá nhân hóa: từ phát âm yếu nhất + phân bố lỗi của user.
  Future<PronunciationInsight> getInsights({int limit = 10}) async {
    final response = await _dio.get(
      '/pronunciation/insights',
      queryParameters: {'limit': limit},
    );
    if (response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid response format from insights endpoint',
      );
    }
    return PronunciationInsight.fromJson(response.data as Map<String, dynamic>);
  }
}
