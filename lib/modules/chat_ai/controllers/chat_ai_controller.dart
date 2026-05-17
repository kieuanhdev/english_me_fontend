import 'package:dio/dio.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/data/models/chat_message_model.dart';
import 'package:englishme/data/repositories/chat_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChatAiController extends GetxController {
  static const int _maxMessageChars = 700;
  static const int _maxHistoryMessages = 6;
  static const int _maxHistoryChars = 2400;

  late final ChatRepository _repository;

  final messages = <ChatMessageModel>[].obs;
  final isSending = false.obs;
  final inputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _repository = ChatRepository(DioClient.instance);
    messages.add(
      const ChatMessageModel(
        role: 'assistant',
        content: 'Xin chào! Hãy gửi câu bạn muốn mình sửa và giải thích.',
      ),
    );
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  Future<void> sendCurrentMessage() async {
    final message = inputController.text.trim();
    if (message.isEmpty || isSending.value) return;
    final safeMessage = _trimToMaxChars(message, _maxMessageChars);

    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) {
      Get.snackbar(
        'Lỗi',
        'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final history = _buildSafeHistory();
    final userMessage = ChatMessageModel(role: 'user', content: safeMessage);
    messages.add(userMessage);
    inputController.clear();
    isSending.value = true;

    try {
      final reply = await _repository.sendMessage(
        message: safeMessage,
        history: history,
        idToken: idToken,
      );
      messages.add(reply);
    } on DioException catch (e) {
      final messageError =
          (e.response?.data is Map<String, dynamic>)
              ? (e.response?.data['message'] as String? ??
                  'Không thể kết nối đến AI.')
              : 'Không thể kết nối đến AI.';
      Get.snackbar('Lỗi', messageError, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Đã có lỗi khi gửi tin nhắn. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  List<ChatMessageModel> _buildSafeHistory() {
    if (messages.isEmpty) return const [];

    final recent = messages.length > _maxHistoryMessages
        ? messages.sublist(messages.length - _maxHistoryMessages)
        : List<ChatMessageModel>.from(messages);

    final normalized = recent
        .map(
          (item) => ChatMessageModel(
            role: item.role,
            content: _trimToMaxChars(item.content, _maxMessageChars),
          ),
        )
        .toList();

    int totalChars = 0;
    final reversed = <ChatMessageModel>[];

    for (int i = normalized.length - 1; i >= 0; i--) {
      final item = normalized[i];
      final nextChars = totalChars + item.content.length;
      if (nextChars > _maxHistoryChars) break;
      reversed.add(item);
      totalChars = nextChars;
    }

    return reversed.reversed.toList();
  }

  String _trimToMaxChars(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return value.substring(0, maxChars);
  }
}
