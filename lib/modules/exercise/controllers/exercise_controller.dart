import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/exercise/models/exercise_model.dart';
import 'package:englishme/modules/exercise/repositories/exercise_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum ExerciseState { idle, loading, playing, submitting, finished, error }

class ExerciseController extends GetxController {
  final ExerciseRepository _repo;
  ExerciseController(this._repo);

  final state = ExerciseState.idle.obs;
  final errorMessage = ''.obs;

  final questions = <ExerciseQuestion>[].obs;
  final currentIndex = 0.obs;
  final selectedAnswer = Rxn<String>();
  final isAnswerRevealed = false.obs;
  final results = <ExerciseAnswerResult>[].obs;
  final Rxn<ExerciseCompleteResponse> completion = Rxn();

  ExerciseCategory? _activeCategory;
  String? _sessionId;

  ExerciseQuestion? get currentExercise =>
      questions.isNotEmpty && currentIndex.value < questions.length
          ? questions[currentIndex.value]
          : null;

  bool get isLastQuestion => currentIndex.value >= questions.length - 1;
  int get correctCount => completion.value?.correct ?? results.where((r) => r.isCorrect).length;
  int get totalAnswered => results.length;
  int get xpEarned => completion.value?.xpEarned ?? 0;

  void startSession(ExerciseCategory category) {
    _reset(category);
    Get.toNamed(AppRoutes.exerciseQuiz);
    _fetchQuestions(category);
  }

  Future<void> _fetchQuestions(ExerciseCategory category) async {
    try {
      state.value = ExerciseState.loading;
      final session = await _repo.getExerciseSession(category: category);
      _sessionId = session.sessionId;
      questions.assignAll(session.questions);
      state.value = ExerciseState.playing;
    } catch (e) {
      if (kDebugMode) debugPrint('[ExerciseController] _fetchQuestions failed: $e');
      errorMessage.value = T.errorLoadTest.tr;
      state.value = ExerciseState.error;
    }
  }

  Future<void> retryLoad() async {
    if (_activeCategory == null) return;
    errorMessage.value = '';
    await _fetchQuestions(_activeCategory!);
  }

  void selectAnswer(String answer) {
    if (isAnswerRevealed.value) return;
    selectedAnswer.value = answer;
  }

  void confirmAnswer() {
    final answer = selectedAnswer.value;
    final q = currentExercise;
    if (answer == null || q == null || isAnswerRevealed.value) return;

    final isCorrect = answer == q.correctAnswer;
    isAnswerRevealed.value = true;
    results.add(ExerciseAnswerResult(
      questionId: q.id,
      selectedAnswer: answer,
      isCorrect: isCorrect,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
    ));
    SoundService.to.play(isCorrect ? AppSound.correct : AppSound.wrong);
  }

  Future<void> nextQuestion() async {
    if (!isAnswerRevealed.value) return;
    if (isLastQuestion) {
      await _submitSession();
      return;
    }
    currentIndex.value++;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
  }

  Future<void> _submitSession() async {
    final sessionId = _sessionId;
    if (sessionId == null) {
      state.value = ExerciseState.finished;
      Get.offNamed(AppRoutes.exerciseResult);
      return;
    }
    try {
      state.value = ExerciseState.submitting;
      final answers = <Map<String, String>>[];
      for (final r in results) {
        final question = questions.firstWhereOrNull((q) => q.id == r.questionId);
        final label = question?.labelFor(r.selectedAnswer) ?? r.selectedAnswer;
        answers.add({'questionId': r.questionId, 'selectedAnswer': label});
      }
      final result = await _repo.completeSession(
        sessionId: sessionId,
        answers: answers,
      );
      completion.value = result;
      XpGrantHandler.apply(
        totalXp: result.totalXp,
        xpEarned: result.xpEarned,
        streakUpdated: result.streakUpdated,
        bonuses: result.bonuses,
      );
      state.value = ExerciseState.finished;
      Get.offNamed(AppRoutes.exerciseResult);
    } catch (e) {
      // Submit lỗi → vẫn sang màn kết quả (UI tự hiển thị trạng thái).
      if (kDebugMode) debugPrint('[ExerciseController] _submitSession failed: $e');
      state.value = ExerciseState.finished;
      Get.offNamed(AppRoutes.exerciseResult);
    }
  }

  void retrySession() {
    if (_activeCategory != null) {
      _reset(_activeCategory!);
      _fetchQuestions(_activeCategory!);
    }
  }

  void closeExercise() {
    Get.until((route) => route.settings.name == AppRoutes.shell || route.isFirst);
    state.value = ExerciseState.idle;
  }

  void _reset(ExerciseCategory category) {
    _activeCategory = category;
    _sessionId = null;
    currentIndex.value = 0;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
    results.clear();
    questions.clear();
    completion.value = null;
  }
}
