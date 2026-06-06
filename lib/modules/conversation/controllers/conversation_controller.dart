import 'package:dio/dio.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/modules/conversation/models/conversation_models.dart';
import 'package:englishme/modules/conversation/repositories/conversation_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Các giai đoạn của một phiên luyện hội thoại.
enum ConversationPhase { chatting, summarizing, summary }

/// Điều phối luyện nói hội thoại voice với AI (giống GPT voice chat):
/// user nói -> STT -> gửi server -> AI trả text -> TTS đọc luôn.
/// Giới hạn 10 lượt user, hết lượt thì tổng kết & nhận xét.
class ConversationController extends GetxController {
  late final ConversationRepository _repository;
  final SpeechToText _speech = SpeechToText();
  TtsService get _tts => Get.find<TtsService>();
  bool _speechReady = false;

  /// Giới hạn lượt người dùng nói để tiết kiệm token.
  static const int maxUserTurns = 10;

  final topic = ''.obs;
  final messages = <ChatMessage>[].obs;

  final isRecording = false.obs;
  final isThinking = false.obs; // đang đợi AI trả lời
  final liveTranscript = ''.obs;
  final userTurnsUsed = 0.obs;

  final phase = ConversationPhase.chatting.obs;
  final summary = Rxn<ConversationSummary>();

  bool get hasTurnsLeft => userTurnsUsed.value < maxUserTurns;
  bool get canRecord =>
      hasTurnsLeft &&
      !isThinking.value &&
      phase.value == ConversationPhase.chatting;

  @override
  void onInit() {
    super.onInit();
    _repository = ConversationRepository(DioClient.instance);
  }

  @override
  void onClose() {
    _speech.cancel();
    _tts.stop();
    super.onClose();
  }

  /// Bắt đầu phiên mới với chủ đề đã chọn. AI chào mở đầu trước.
  Future<void> startConversation(String topicValue) async {
    topic.value = topicValue.trim();
    messages.clear();
    userTurnsUsed.value = 0;
    liveTranscript.value = '';
    summary.value = null;
    phase.value = ConversationPhase.chatting;
    await _fetchAiReply(isOpening: true);
  }

  Future<void> startRecording() async {
    if (!canRecord) return;
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      AppNotify.error('Lỗi quyền', message: 'Cần cấp quyền micro để luyện nói.');
      return;
    }

    await _tts.stop();

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (_) {
          isRecording.value = false;
        },
      );
    }
    if (!_speechReady) {
      AppNotify.error('Lỗi', message: 'Không khởi tạo được nhận dạng giọng nói.');
      return;
    }

    liveTranscript.value = '';
    isRecording.value = true;
    await _speech.listen(
      onResult: (result) => liveTranscript.value = result.recognizedWords,
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        localeId: 'en_US',
      ),
    );
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    await _speech.stop();
    isRecording.value = false;
    await _submitTranscript();
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (isRecording.value) {
        isRecording.value = false;
        _submitTranscript();
      }
    }
  }

  /// Gửi câu user vừa nói, lấy câu trả lời AI rồi đọc bằng TTS.
  Future<void> _submitTranscript() async {
    final spoken = liveTranscript.value.trim();
    liveTranscript.value = '';
    if (spoken.isEmpty || phase.value != ConversationPhase.chatting) return;

    messages.add(ChatMessage(role: 'user', content: spoken));
    userTurnsUsed.value += 1;
    await _fetchAiReply();

    if (!hasTurnsLeft) {
      await finishAndSummarize();
    }
  }

  Future<void> _fetchAiReply({bool isOpening = false}) async {
    isThinking.value = true;
    try {
      final reply = await _repository.chat(
        topic: topic.value,
        history: messages.toList(),
      );
      if (reply.isNotEmpty) {
        messages.add(ChatMessage(role: 'assistant', content: reply));
        await _tts.speak(reply);
      }
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message'] as String? ?? 'Không gửi được tin nhắn.')
          : 'Lỗi kết nối máy chủ.';
      AppNotify.error('Lỗi', message: msg);
    } catch (_) {
      AppNotify.error('Lỗi', message: 'Đã xảy ra lỗi khi trò chuyện.');
    } finally {
      isThinking.value = false;
    }
  }

  /// Kết thúc hội thoại -> gọi server tổng kết & nhận xét.
  Future<void> finishAndSummarize() async {
    if (phase.value == ConversationPhase.summarizing) return;
    await _tts.stop();
    if (isRecording.value) {
      await _speech.stop();
      isRecording.value = false;
    }
    phase.value = ConversationPhase.summarizing;
    try {
      summary.value = await _repository.summarize(
        topic: topic.value,
        history: messages.toList(),
      );
      phase.value = ConversationPhase.summary;
      Get.toNamed(AppRoutes.conversationSummary);
    } on DioException {
      phase.value = ConversationPhase.chatting;
      AppNotify.error('Lỗi', message: 'Không tổng kết được. Thử lại sau.');
    } catch (_) {
      phase.value = ConversationPhase.chatting;
      AppNotify.error('Lỗi', message: 'Đã xảy ra lỗi khi tổng kết.');
    }
  }

  /// Về màn chọn chủ đề để luyện chủ đề khác.
  void resetSession() {
    _tts.stop();
    _speech.cancel();
    messages.clear();
    userTurnsUsed.value = 0;
    liveTranscript.value = '';
    summary.value = null;
    topic.value = '';
    phase.value = ConversationPhase.chatting;
    Get.until((route) => Get.currentRoute == AppRoutes.conversation);
  }

  void replay(String text) => _tts.speak(text);
}
