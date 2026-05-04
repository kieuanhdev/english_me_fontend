import 'package:dio/dio.dart';
import 'package:englishme/data/models/chat_message_model.dart';

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<ChatMessageModel> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
    required String idToken,
  }) async {
    final response = await _dio.post(
      '/chat',
      data: {
        'message': message,
        'history': history.map((item) => item.toHistoryJson()).toList(),
      },
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    final data = response.data as Map<String, dynamic>;
    return ChatMessageModel(
      role: 'assistant',
      content: data['reply'] as String? ?? '',
      model: data['model'] as String?,
    );
  }
}
