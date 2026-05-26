import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsService extends GetxService {
  late final FlutterTts _tts;
  final isSpeaking = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _tts = FlutterTts();
    await _configure();
    // Warm-up: speak empty string để engine khởi động sẵn
    try {
      await _tts.speak(' ');
    } catch (_) {}
  }

  Future<void> _configure() async {
    try {
      final langs = await _tts.getLanguages;
      final hasEnglish = langs.any(
        (lang) => (lang as String).toLowerCase().startsWith('en'),
      );
      if (hasEnglish) await _tts.setLanguage('en-US');
    } catch (_) {}

    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(false);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
