import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsService extends GetxService {
  late final FlutterTts _tts;
  final isSpeaking = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _tts = FlutterTts();

    final langs = await _tts.getLanguages;
    final hasEnglish = langs.any(
      (lang) => (lang as String).toLowerCase().startsWith('en'),
    );
    if (hasEnglish) {
      await _tts.setLanguage('en-US');
    }

    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);
  }

  Future<void> speak(String text) async {
    try {
      await _tts.stop();
      final result = await _tts.speak(text);
      if (result == 0) {
        // TTS failed silently — retry without awaiting completion
        await _tts.stop();
        await _tts.speak(text);
      }
    } catch (_) {
      // fallback: try direct speak
      try {
        await _tts.speak(text);
      } catch (_) {}
    }
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
