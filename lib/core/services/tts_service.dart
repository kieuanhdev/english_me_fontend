import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService extends GetxService {
  late final FlutterTts _tts;
  final isSpeaking = false.obs;
  // Text hiện đang đọc (rỗng nếu không đọc) — để UI biết NÚT NÀO đang phát,
  // tránh mọi nút loa cùng đổi icon khi chỉ 1 từ được đọc.
  final speakingText = ''.obs;

  // Tự phát âm khi mở thẻ mới (study session). Bật mặc định; lưu persist.
  static const String _autoSpeakKey = 'tts_auto_speak';
  final autoSpeak = true.obs;
  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _tts = FlutterTts();
    await _loadPrefs();
    await _configure();
    // Warm-up: speak empty string để engine khởi động sẵn
    try {
      await _tts.speak(' ');
    } catch (_) {}
  }

  Future<void> _loadPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    autoSpeak.value = _prefs!.getBool(_autoSpeakKey) ?? true;
  }

  Future<void> setAutoSpeak(bool value) async {
    autoSpeak.value = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_autoSpeakKey, value);
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
    _tts.setCompletionHandler(() {
      isSpeaking.value = false;
      speakingText.value = '';
    });
    _tts.setErrorHandler((_) {
      isSpeaking.value = false;
      speakingText.value = '';
    });
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      speakingText.value = text;
      await _tts.speak(text);
    } catch (_) {
      speakingText.value = '';
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
    speakingText.value = '';
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
