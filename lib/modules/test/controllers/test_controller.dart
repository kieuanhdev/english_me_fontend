import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/test/models/test_model.dart';
import 'package:englishme/modules/test/repositories/test_repository.dart';
import 'package:englishme/routes/app_routes.dart';

class TestController extends GetxController {
  late final TestRepository _repo;

  final state = TestState.idle.obs;
  final errorMessage = ''.obs;

  final selectedTopic = Rxn<TestTopic>();
  final selectedLevel = Rxn<TestLevel>();

  final questions = <TestQuestion>[].obs;
  final currentIndex = 0.obs;
  final selectedAnswer = Rxn<String>();
  final isAnswerRevealed = false.obs;
  final results = <TestAnswerResult>[].obs;
  final Rxn<TestSubmitResponse> submission = Rxn();

  final secondsRemaining = 0.obs;
  Timer? _timer;

  final history = <TestHistoryEntry>[].obs;
  final isHistoryLoading = false.obs;

  String? _sessionId;
  int _initialDuration = 0;

  @override
  void onInit() {
    super.onInit();
    _repo = TestRepository(DioClient.instance);
    _loadHistory();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  TestQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex.value < questions.length
          ? questions[currentIndex.value]
          : null;

  bool get isLastQuestion => currentIndex.value >= questions.length - 1;
  int get correctCount =>
      submission.value?.correct ?? results.where((r) => r.isCorrect).length;
  int get totalAnswered => results.length;
  int get xpEarned => submission.value?.xpEarned ?? 0;
  String? get cefrSuggestion => submission.value?.cefrSuggestion;

  String get timerDisplay {
    final m = secondsRemaining.value ~/ 60;
    final s = secondsRemaining.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isTimerWarning => secondsRemaining.value <= 60;

  void selectTopic(TestTopic topic) => selectedTopic.value = topic;
  void selectLevel(TestLevel level) => selectedLevel.value = level;

  Future<void> startTest() async {
    final topic = selectedTopic.value;
    final level = selectedLevel.value;
    if (topic == null || level == null) return;

    _reset();
    Get.toNamed(AppRoutes.testQuestion);
    await _fetchQuestions(topic, level);
  }

  Future<void> _fetchQuestions(TestTopic topic, TestLevel level) async {
    try {
      state.value = TestState.loading;
      final session = await _repo.getTestSession(topic: topic, level: level);
      _sessionId = session.sessionId;
      _initialDuration = session.durationSeconds;
      questions.assignAll(session.questions);
      secondsRemaining.value = session.durationSeconds;
      state.value = TestState.playing;
      _startTimer();
    } catch (e) {
      if (kDebugMode) debugPrint('[TestController] _fetchQuestions failed: $e');
      errorMessage.value = T.errorLoadTest.tr;
      state.value = TestState.error;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining.value <= 0) {
        _timer?.cancel();
        _finishTest();
        return;
      }
      secondsRemaining.value--;
    });
  }

  void selectAnswer(String answer) {
    if (isAnswerRevealed.value) return;
    selectedAnswer.value = answer;
  }

  void confirmAnswer() {
    final answer = selectedAnswer.value;
    final q = currentQuestion;
    if (answer == null || q == null || isAnswerRevealed.value) return;

    final isCorrect = answer == q.correctAnswer;
    isAnswerRevealed.value = true;
    results.add(TestAnswerResult(
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
      await _finishTest();
      return;
    }
    currentIndex.value++;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
  }

  Future<void> _finishTest() async {
    _timer?.cancel();
    final sessionId = _sessionId;
    if (sessionId == null) {
      state.value = TestState.finished;
      Get.offNamed(AppRoutes.testResult);
      return;
    }
    try {
      state.value = TestState.submitting;
      final answers = <Map<String, String>>[];
      for (final r in results) {
        final q = questions.firstWhereOrNull((e) => e.id == r.questionId);
        final label = q?.labelFor(r.selectedAnswer) ?? r.selectedAnswer;
        answers.add({'questionId': r.questionId, 'selectedAnswer': label});
      }
      final timeTaken = _initialDuration - secondsRemaining.value;
      final result = await _repo.submitTest(
        sessionId: sessionId,
        answers: answers,
        timeTakenSeconds: timeTaken < 0 ? 0 : timeTaken,
      );
      submission.value = result;
      XpGrantHandler.apply(
        totalXp: result.totalXp,
        xpEarned: result.xpEarned,
        streakUpdated: result.streakUpdated,
        bonuses: result.bonuses,
        newBadges: result.newBadges,
      );
      state.value = TestState.finished;
      Get.offNamed(AppRoutes.testResult);
      unawaited(_loadHistory()); // nạp lịch sử nền, không chặn điều hướng
    } catch (e) {
      // Submit lỗi → vẫn sang màn kết quả (UI tự hiển thị trạng thái).
      if (kDebugMode) debugPrint('[TestController] _finishTest failed: $e');
      state.value = TestState.finished;
      Get.offNamed(AppRoutes.testResult);
    }
  }

  Future<void> submitTest() async {
    if (!isAnswerRevealed.value && selectedAnswer.value != null) {
      confirmAnswer();
    }
    await _finishTest();
  }

  Future<void> retryTest() async {
    final topic = selectedTopic.value;
    final level = selectedLevel.value;
    if (topic == null || level == null) return;
    _reset();
    await _fetchQuestions(topic, level);
  }

  void closeTest() {
    _timer?.cancel();
    Get.until((route) => route.settings.name == AppRoutes.shell || route.isFirst);
    state.value = TestState.idle;
  }

  Future<void> _loadHistory() async {
    try {
      isHistoryLoading.value = true;
      final data = await _repo.getTestHistory();
      history.assignAll(data);
    } catch (e) {
      // history là phụ — lỗi không chặn UI, chỉ log để debug.
      if (kDebugMode) debugPrint('[TestController] _loadHistory failed: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void _reset() {
    _sessionId = null;
    _initialDuration = 0;
    currentIndex.value = 0;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
    results.clear();
    questions.clear();
    submission.value = null;
    secondsRemaining.value = 0;
    _timer?.cancel();
  }
}
