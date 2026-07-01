import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/dictation/models/dictation_models.dart';
import 'package:englishme/modules/dictation/repositories/dictation_repository.dart';

enum DictationState { idle, loading, playing, submitting, finished, error }

class DictationController extends GetxController {
  final DictationRepository _repo;
  DictationController(this._repo);

  final state = DictationState.idle.obs;
  final errorMessage = ''.obs;

  final sentences = <DictationSentence>[].obs;
  final currentIndex = 0.obs;
  final isRevealed = false.obs;
  final lastCorrect = false.obs;
  /// Diff từng từ của lần trả lời hiện tại (để highlight đúng/sai).
  final diff = <DictationWordDiff>[].obs;

  final Rxn<DictationCompleteResult> completion = Rxn();

  String? _sessionId;
  String? _level;
  String? _lessonId;
  int _correctCount = 0;

  @override
  void onReady() {
    super.onReady();
    // Mở từ Home (Luyện tập nhanh → Nghe): tự bắt đầu với level CEFR truyền qua args.
    // Mở từ trong 1 bài giáo trình (lesson player → "Luyện nghe câu trong bài"):
    // truyền thêm lessonId để chép chính tả ĐÚNG câu của bài đó (B xoay quanh A).
    final args = Get.arguments;
    if (args is Map && (args['level'] is String || args['lessonId'] is String)) {
      start(
        level: args['level'] as String?,
        lessonId: args['lessonId'] as String?,
      );
    } else if (sentences.isEmpty && state.value == DictationState.idle) {
      start();
    }
  }

  DictationSentence? get current =>
      sentences.isNotEmpty && currentIndex.value < sentences.length
          ? sentences[currentIndex.value]
          : null;

  bool get isLast => currentIndex.value >= sentences.length - 1;
  int get correctCount => completion.value?.correct ?? _correctCount;
  int get total => sentences.length;
  int get xpEarned => completion.value?.xpEarned ?? 0;

  void start({String? level, String? lessonId}) {
    _level = level;
    _lessonId = lessonId;
    _reset();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      state.value = DictationState.loading;
      final session = await _repo.getSession(level: _level, lessonId: _lessonId);
      _sessionId = session.sessionId;
      sentences.assignAll(session.sentences);
      state.value =
          sentences.isEmpty ? DictationState.error : DictationState.playing;
      if (sentences.isEmpty) errorMessage.value = 'Chưa có câu luyện nghe.';
    } catch (e) {
      if (kDebugMode) debugPrint('[DictationController] _fetch failed: $e');
      errorMessage.value = T.errorLoadTest.tr;
      state.value = DictationState.error;
    }
  }

  Future<void> retry() async {
    errorMessage.value = '';
    _reset();
    await _fetch();
  }

  /// Phát lại câu hiện tại bằng TTS (đọc chậm cho dễ chép).
  Future<void> playCurrent() async {
    final s = current;
    if (s == null) return;
    await Get.find<TtsService>().speakSlow(s.text);
  }

  /// Chấm bài user vừa gõ. So khớp chuẩn hóa toàn câu; diff theo từng từ.
  void check(String typed) {
    final s = current;
    if (s == null || isRevealed.value) return;

    final correct = _normalize(typed) == _normalize(s.text);
    diff.assignAll(_buildDiff(typed, s.text));
    lastCorrect.value = correct;
    isRevealed.value = true;
    if (correct) _correctCount++;
    SoundService.to.play(correct ? AppSound.correct : AppSound.wrong);
  }

  Future<void> next() async {
    if (!isRevealed.value) return;
    if (isLast) {
      await _submit();
      return;
    }
    currentIndex.value++;
    isRevealed.value = false;
    lastCorrect.value = false;
    diff.clear();
  }

  Future<void> _submit() async {
    final sessionId = _sessionId;
    if (sessionId == null) {
      state.value = DictationState.finished;
      return;
    }
    try {
      state.value = DictationState.submitting;
      final result = await _repo.complete(
        sessionId: sessionId,
        correct: _correctCount,
        total: sentences.length,
      );
      completion.value = result;
      XpGrantHandler.apply(
        totalXp: result.totalXp,
        xpEarned: result.xpEarned,
        streakUpdated: result.streakUpdated,
        newBadges: result.newBadges,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[DictationController] _submit failed: $e');
    } finally {
      state.value = DictationState.finished;
    }
  }

  void _reset() {
    _sessionId = null;
    _correctCount = 0;
    currentIndex.value = 0;
    isRevealed.value = false;
    lastCorrect.value = false;
    diff.clear();
    sentences.clear();
    completion.value = null;
  }

  // ── Chấm chuẩn hóa ──────────────────────────────────────────────────────────
  /// lowercase + bỏ dấu câu + gộp khoảng trắng. Khớp 100% (sau chuẩn hóa) = đúng.
  static String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s']"), ' ') // bỏ dấu câu, giữ chữ/số/space/'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Diff theo từ (so token đã chuẩn hóa) để highlight từng từ user gõ.
  static List<DictationWordDiff> _buildDiff(String typed, String answer) {
    final typedWords = _normalize(typed).split(' ').where((w) => w.isNotEmpty).toList();
    final answerWords =
        _normalize(answer).split(' ').where((w) => w.isNotEmpty).toList();
    // Hiển thị từ ĐÁP ÁN, đánh dấu từ nào user gõ đúng vị trí.
    final result = <DictationWordDiff>[];
    final answerDisplay = answer.split(RegExp(r'\s+'));
    for (var i = 0; i < answerDisplay.length; i++) {
      final norm = i < answerWords.length ? answerWords[i] : '';
      final ok = i < typedWords.length && typedWords[i] == norm;
      result.add(DictationWordDiff(answerDisplay[i], ok));
    }
    return result;
  }
}

/// 1 từ trong đáp án + user gõ đúng vị trí đó hay không.
class DictationWordDiff {
  final String word;
  final bool correct;
  const DictationWordDiff(this.word, this.correct);
}
