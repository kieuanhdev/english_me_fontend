import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Các hiệu ứng âm thanh phản hồi trong app.
/// Mỗi giá trị map tới 1 file trong `assets/sounds/`.
enum AppSound {
  /// Trả lời đúng 1 câu.
  correct('correct.mp3'),

  /// Trả lời sai 1 câu.
  wrong('wrong.mp3'),

  /// Hoàn thành 1 bài tập/test/phiên ôn (sang màn kết quả).
  complete('complete.mp3'),

  /// Đạt mục tiêu XP trong ngày (daily goal).
  dailyGoal('daily_goal.mp3'),

  /// Lên cấp CEFR / vượt checkpoint.
  levelUp('level_up.mp3');

  const AppSound(this.file);

  /// Tên file trong `assets/sounds/`.
  final String file;
}

/// Phát hiệu ứng âm thanh ngắn (sfx) cho các mốc trong app: trả lời đúng/sai,
/// hoàn thành bài, đạt mục tiêu ngày, lên cấp.
///
/// Thiết kế phòng thủ:
///  - Nếu file âm thanh chưa được thêm vào `assets/sounds/`, [play] nuốt lỗi
///    (không crash) — app vẫn rung haptic như fallback.
///  - User có thể tắt âm hiệu ứng qua [enabled] (lưu vào SharedPreferences).
///  - Tách [AudioPlayer] riêng khỏi TTS/word-of-day để không cướp luồng đọc từ.
class SoundService extends GetxService {
  static const _prefsKey = 'sfx_enabled';

  /// Bật/tắt âm thanh hiệu ứng. Mặc định bật.
  final RxBool enabled = true.obs;

  SharedPreferences? _prefs;

  /// Lấy instance đã đăng ký, hoặc tạo mới nếu chưa (an toàn để gọi ở mọi nơi).
  static SoundService get to => Get.isRegistered<SoundService>()
      ? Get.find<SoundService>()
      : Get.put(SoundService());

  @override
  Future<void> onInit() async {
    super.onInit();
    // sfx nên phát chồng (low latency), không bị TTS/nhạc khác chiếm focus.
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
    } catch (e) {
      // Cấu hình audio context lỗi (tuỳ nền tảng) → sfx vẫn phát ở mode mặc định.
      if (kDebugMode) debugPrint('[SoundService] setAudioContext failed: $e');
    }
    try {
      _prefs = await SharedPreferences.getInstance();
      enabled.value = _prefs?.getBool(_prefsKey) ?? true;
    } catch (_) {
      // Không có prefs cũng không sao — mặc định bật.
    }
  }

  /// Bật/tắt và lưu lựa chọn.
  Future<void> setEnabled(bool value) async {
    enabled.value = value;
    try {
      await _prefs?.setBool(_prefsKey, value);
    } catch (e) {
      // Lưu prefs lỗi → giá trị runtime vẫn đúng, chỉ không persist.
      if (kDebugMode) debugPrint('[SoundService] setEnabled persist failed: $e');
    }
  }

  /// Phát 1 hiệu ứng. Luôn kèm haptic nhẹ làm fallback (kể cả khi thiếu file).
  ///
  /// Mỗi lần phát dùng 1 [AudioPlayer] mới (low latency, tự release) — cách này
  /// đáng tin nhất cho sfx ngắn, cho phép chồng tiếng và tránh race với
  /// `stop()` trên player dùng lại.
  Future<void> play(AppSound sound) async {
    if (!enabled.value) return;
    _haptic(sound);
    final player = AudioPlayer(playerId: 'sfx_${sound.name}');
    try {
      await player.setReleaseMode(ReleaseMode.release);
      await player.setVolume(1.0);
      // Tự dọn player sau khi phát xong để không rò bộ nhớ.
      player.onPlayerComplete.first.then((_) => player.dispose());
      // Dùng mediaPlayer (mode mặc định, ổn định nhất mọi nền tảng). lowLatency
      // hay im lặng/throw tuỳ thiết bị nên ta tránh.
      await player.play(
        AssetSource('sounds/${sound.file}'),
        mode: PlayerMode.mediaPlayer,
      );
    } catch (e) {
      // File chưa tồn tại / lỗi codec → bỏ qua, haptic ở trên là đủ phản hồi.
      if (kDebugMode) {
        debugPrint('[SoundService] play ${sound.file} failed: $e');
      }
      try {
        await player.dispose();
      } catch (_) {
        // dispose lỗi trong nhánh xử lý lỗi → không cần log thêm.
      }
    }
  }

  void _haptic(AppSound sound) {
    try {
      switch (sound) {
        case AppSound.correct:
          HapticFeedback.lightImpact();
        case AppSound.wrong:
          HapticFeedback.vibrate();
        case AppSound.complete:
        case AppSound.dailyGoal:
        case AppSound.levelUp:
          HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Thiết bị không hỗ trợ haptic → bỏ qua.
      if (kDebugMode) debugPrint('[SoundService] haptic failed: $e');
    }
  }

  // Mỗi lần phát tạo player riêng và tự dispose khi xong, nên không có player
  // dài hạn cần dọn ở đây.
}
