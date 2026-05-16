import 'dart:async';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
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

  final secondsRemaining = 0.obs;
  Timer? _timer;

  final history = <TestHistoryEntry>[].obs;
  final isHistoryLoading = false.obs;

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
  int get correctCount => results.where((r) => r.isCorrect).length;
  int get totalAnswered => results.length;

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
      questions.assignAll(session.questions);
      secondsRemaining.value = session.durationSeconds;
      state.value = TestState.playing;
      _startTimer();
    } catch (e) {
      errorMessage.value = 'Không thể tải bài kiểm tra. Vui lòng thử lại.';
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

    isAnswerRevealed.value = true;
    results.add(TestAnswerResult(
      questionId: q.id,
      selectedAnswer: answer,
      isCorrect: answer == q.correctAnswer,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
    ));
  }

  void nextQuestion() {
    if (!isAnswerRevealed.value) return;
    if (isLastQuestion) {
      _finishTest();
      return;
    }
    currentIndex.value++;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
  }

  void _finishTest() {
    _timer?.cancel();
    state.value = TestState.finished;

    final topic = selectedTopic.value;
    final level = selectedLevel.value;
    if (topic != null && level != null) {
      history.insert(
        0,
        TestHistoryEntry(
          sessionId: 'test-${DateTime.now().millisecondsSinceEpoch}',
          topic: topic,
          level: level,
          correct: correctCount,
          total: totalAnswered,
          completedAt: DateTime.now(),
        ),
      );
    }

    Get.offNamed(AppRoutes.testResult);
  }

  void submitTest() {
    if (!isAnswerRevealed.value && selectedAnswer.value != null) {
      confirmAnswer();
    }
    _finishTest();
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
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void _reset() {
    currentIndex.value = 0;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
    results.clear();
    questions.clear();
    secondsRemaining.value = 0;
    _timer?.cancel();
  }
}
