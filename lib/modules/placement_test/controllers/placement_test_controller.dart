import 'dart:async';

import 'package:get/get.dart';

import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/placement_test/models/placement_test_models.dart';
import 'package:englishme/modules/placement_test/repositories/placement_test_repository.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/routes/app_routes.dart';

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
      final response = await _repository.startTest();
      _sessionId = response.sessionId;
      questions.assignAll(response.questions);
      currentIndex.value = 0;
      selectedAnswer.value = null;
      answerResponse.value = null;
      state.value = PlacementTestState.questioning;
    } catch (_) {
      _showError(T.errorStartPlacement.tr);
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
      final response = await _repository.answerQuestion(
        _sessionId,
        question.id,
        answer,
      );
      answerResponse.value = response;
      state.value = PlacementTestState.questioning;
    } catch (_) {
      state.value = PlacementTestState.questioning;
      Get.snackbar(T.errorGeneric.tr, T.errorSubmitAnswer.tr, snackPosition: SnackPosition.BOTTOM);
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
      final result = await _repository.completeTest(_sessionId);
      testResult.value = result;
      state.value = PlacementTestState.completed;
      // Refresh profile để Home/Profile thấy CEFR mới ngay lập tức.
      if (Get.isRegistered<ProfileController>()) {
        unawaited(Get.find<ProfileController>().loadProfile());
      }
      Get.offNamed(AppRoutes.placementTestResult);
    } catch (_) {
      _completing = false;
      _showError(T.errorCompletePlacement.tr);
    }
  }

  void _showError(String message) {
    errorMessage.value = message;
    state.value = PlacementTestState.error;
    Get.snackbar(T.errorGeneric.tr, message, snackPosition: SnackPosition.BOTTOM);
  }
}
