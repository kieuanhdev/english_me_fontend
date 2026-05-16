import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/exercise/models/exercise_model.dart';
import 'package:englishme/modules/exercise/repositories/exercise_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum ExerciseState { idle, loading, playing, finished, error }

class ExerciseController extends GetxController {
  late final ExerciseRepository _repo;

  final state = ExerciseState.idle.obs;
  final errorMessage = ''.obs;

  final questions = <ExerciseQuestion>[].obs;
  final currentIndex = 0.obs;
  final selectedAnswer = Rxn<String>();
  final isAnswerRevealed = false.obs;
  final results = <ExerciseAnswerResult>[].obs;

  ExerciseCategory? _activeCategory;

  @override
  void onInit() {
    super.onInit();
    _repo = ExerciseRepository(DioClient.instance);
  }

  ExerciseQuestion? get currentExercise =>
      questions.isNotEmpty && currentIndex.value < questions.length
          ? questions[currentIndex.value]
          : null;

  bool get isLastQuestion => currentIndex.value >= questions.length - 1;
  int get correctCount => results.where((r) => r.isCorrect).length;
  int get totalAnswered => results.length;

  void startSession(ExerciseCategory category) {
    _reset(category);
    // Navigate trước rồi load data — không bị block bởi lỗi mạng
    Get.toNamed(AppRoutes.exerciseQuiz);
    _fetchQuestions(category);
  }

  Future<void> _fetchQuestions(ExerciseCategory category) async {
    try {
      state.value = ExerciseState.loading;
      final session = await _repo.getExerciseSession(category: category);
      questions.assignAll(session.questions);
      state.value = ExerciseState.playing;
    } catch (e) {
      errorMessage.value = 'Không thể tải bài tập. Vui lòng thử lại.';
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

    isAnswerRevealed.value = true;
    results.add(ExerciseAnswerResult(
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
      state.value = ExerciseState.finished;
      Get.offNamed(AppRoutes.exerciseResult);
      return;
    }
    currentIndex.value++;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
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
    currentIndex.value = 0;
    selectedAnswer.value = null;
    isAnswerRevealed.value = false;
    results.clear();
    questions.clear();
  }
}
