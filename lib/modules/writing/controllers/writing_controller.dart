import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/writing/models/writing_models.dart';
import 'package:englishme/modules/writing/repositories/writing_repository.dart';

enum WritingState { loadingPrompt, writing, grading, result, error }

/// Luyện Viết theo đề với AI: sinh đề theo CEFR → người học viết → AI chấm
/// (điểm + bản sửa + nhận xét) + cộng XP (skill=writing). 1 đề/phiên.
class WritingController extends GetxController {
  final WritingRepository _repo;
  WritingController(this._repo);

  final state = WritingState.loadingPrompt.obs;
  final errorMessage = ''.obs;
  final Rxn<WritingPrompt> prompt = Rxn();
  final Rxn<WritingGrade> grade = Rxn();

  /// Level CEFR truyền từ Home (arguments). Null → backend fallback A1.
  String? _level;

  /// Mở từ trong 1 bài giáo trình → đề viết bám chủ đề/từ vựng bài đó (B xoay quanh A).
  String? _lessonId;

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args is Map) {
      if (args['level'] is String) _level = args['level'] as String;
      if (args['lessonId'] is String) _lessonId = args['lessonId'] as String;
    }
    loadPrompt();
  }

  Future<void> loadPrompt() async {
    try {
      state.value = WritingState.loadingPrompt;
      errorMessage.value = '';
      grade.value = null;
      prompt.value = await _repo.getPrompt(level: _level, lessonId: _lessonId);
      state.value = WritingState.writing;
    } catch (e) {
      if (kDebugMode) debugPrint('[WritingController] loadPrompt failed: $e');
      errorMessage.value = T.errorLoadTest.tr;
      state.value = WritingState.error;
    }
  }

  Future<void> submit(String essay) async {
    final p = prompt.value;
    if (p == null || essay.trim().isEmpty) return;
    try {
      state.value = WritingState.grading;
      final result = await _repo.grade(prompt: p, essay: essay.trim());
      grade.value = result;
      XpGrantHandler.apply(
        totalXp: result.totalXp,
        xpEarned: result.xpEarned,
        streakUpdated: result.streakUpdated,
        newBadges: result.newBadges,
      );
      state.value = WritingState.result;
    } catch (e) {
      if (kDebugMode) debugPrint('[WritingController] submit failed: $e');
      errorMessage.value = 'Không chấm được bài. Thử lại sau.';
      state.value = WritingState.writing;
    }
  }

  /// "Bài khác" → sinh đề mới.
  void nextPrompt() => loadPrompt();
}
