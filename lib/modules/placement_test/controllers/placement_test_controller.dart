import 'package:firebase_auth/firebase_auth.dart';
import 'package:englishme/data/models/placement_test_models.dart';
import 'package:englishme/data/repositories/placement_test_repository.dart';
import 'package:get/get.dart';

enum PlacementTestState { idle, loading, questioning, submitting, completed, error }

class PlacementTestController extends GetxController {
  final PlacementTestRepository _repository;

  PlacementTestController(this._repository);

  final state = PlacementTestState.idle.obs;
  final questions = <QuestionModel>[].obs;
  final currentIndex = 0.obs;
  final selectedAnswer = Rxn<String>();
  final answerResponse = Rxn<AnswerResponseModel>();
  final testResult = Rxn<TestResultModel>();
  final errorMessage = ''.obs;

  String _sessionId = '';
  bool _completing = false;

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex.value < questions.length
          ? questions[currentIndex.value]
          : null;

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex.value) / questions.length;

  bool get isAnswered => answerResponse.value != null;

  bool get isLastQuestion =>
      currentIndex.value >= questions.length - 1;

  Future<void> startTest() async {
    try {
      state.value = PlacementTestState.loading;
      final idToken = await _getIdToken();
      if (idToken == null) {
        _showError('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
        return;
      }
      final response = await _repository.startTest(idToken);
      _sessionId = response.sessionId;
      questions.assignAll(response.questions);
      currentIndex.value = 0;
      selectedAnswer.value = null;
      answerResponse.value = null;
      state.value = PlacementTestState.questioning;
    } catch (_) {
      _showError('Không thể bắt đầu bài kiểm tra. Vui lòng thử lại.');
    }
  }

  void selectAnswer(String answerId) {
    if (isAnswered) return;
    selectedAnswer.value = answerId;
  }

  Future<void> submitAnswer() async {
    if (state.value == PlacementTestState.submitting || isAnswered) return;
    final answer = selectedAnswer.value;
    final question = currentQuestion;
    if (answer == null || question == null) return;

    try {
      state.value = PlacementTestState.submitting;
      final idToken = await _getIdToken();
      if (idToken == null) {
        _showError('Phiên đăng nhập hết hạn.');
        return;
      }
      final response = await _repository.answerQuestion(
        _sessionId,
        idToken,
        question.id,
        answer,
      );
      answerResponse.value = response;
      state.value = PlacementTestState.questioning;
    } catch (_) {
      state.value = PlacementTestState.questioning;
      Get.snackbar('Lỗi', 'Không thể gửi câu trả lời. Vui lòng thử lại.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> nextQuestion() async {
    if (state.value == PlacementTestState.loading || state.value == PlacementTestState.completed) return;
    if (isLastQuestion) {
      state.value = PlacementTestState.loading;
      await _completeTest();
      return;
    }
    currentIndex.value++;
    selectedAnswer.value = null;
    answerResponse.value = null;
  }

  Future<void> _completeTest() async {
    if (_completing) return;
    _completing = true;
    try {
      state.value = PlacementTestState.loading;
      final idToken = await _getIdToken();
      if (idToken == null) {
        _showError('Phiên đăng nhập hết hạn.');
        return;
      }
      final result = await _repository.completeTest(_sessionId, idToken);
      testResult.value = result;
      state.value = PlacementTestState.completed;
      Get.offNamed('/placement-test/result');
    } catch (_) {
      _completing = false;
      _showError('Không thể hoàn thành bài kiểm tra. Vui lòng thử lại.');
    }
  }

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken();
  }

  void _showError(String message) {
    errorMessage.value = message;
    state.value = PlacementTestState.error;
    Get.snackbar('Lỗi', message, snackPosition: SnackPosition.BOTTOM);
  }
}
