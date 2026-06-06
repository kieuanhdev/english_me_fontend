import 'package:dio/dio.dart';
import 'package:englishme/modules/conversation/models/conversation_models.dart';

/// Gọi backend luyện nói hội thoại với AI (DeepSeek). Stateless: gửi full lịch sử.
class ConversationRepository {
  ConversationRepository(this._dio);

  final Dio _dio;

  /// Một lượt hội thoại: gửi chủ đề + lịch sử (gồm câu user vừa nói) -> câu AI.
  Future<String> chat({
    required String topic,
    required List<ChatMessage> history,
  }) async {
    final response = await _dio.post(
      '/conversation/chat',
      data: {
        'topic': topic,
        'history': history.map((m) => m.toJson()).toList(),
      },
    );
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return (body['reply'] as String?)?.trim() ?? '';
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Invalid response format from conversation/chat',
    );
  }

  /// Tổng kết & nhận xét cả đoạn hội thoại.
  Future<ConversationSummary> summarize({
    required String topic,
    required List<ChatMessage> history,
  }) async {
    final response = await _dio.post(
      '/conversation/summary',
      data: {
        'topic': topic,
        'history': history.map((m) => m.toJson()).toList(),
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid response format from conversation/summary',
      );
    }
    return ConversationSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
