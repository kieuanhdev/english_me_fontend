import 'dart:async';

import 'package:englishme/core/utils/app_notify.dart';
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

  /// Thông báo giới hạn từ backend (bài đầu vào chỉ xác định tối đa B2).
  final notice = ''.obs;

  /// Đang lưu trình độ tự chọn (chặn double-tap nút xác nhận).
  final isSelfSelecting = false.obs;

  /// Level CEFR đang được chọn ở màn tự chọn trình độ.
  final selfSelectedLevel = Rxn<String>();

  /// Các mức CEFR cho phép tự chọn (khớp CEFR_ORDER ở backend).
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  void selectLevel(String level) => selfSelectedLevel.value = level;

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
      notice.value = response.notice;
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
      AppNotify.error(T.errorGeneric.tr, message: T.errorSubmitAnswer.tr);
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

  /// Học viên tự chọn trình độ (không làm bài kiểm tra).
  /// Lưu level + onboarded ở backend, refresh profile rồi vào Dashboard.
  Future<void> selfSelectLevel(String level) async {
    if (isSelfSelecting.value) return;
    try {
      isSelfSelecting.value = true;
      await _repository.selfSelectLevel(level);
      // Refresh profile để Home/Profile thấy CEFR mới ngay lập tức.
      if (Get.isRegistered<ProfileController>()) {
        unawaited(Get.find<ProfileController>().loadProfile());
      }
      Get.offAllNamed(AppRoutes.shell);
    } catch (_) {
      AppNotify.error(T.errorGeneric.tr, message: T.placementSelfSelectError.tr);
    } finally {
      isSelfSelecting.value = false;
    }
  }

  void _showError(String message) {
    errorMessage.value = message;
    state.value = PlacementTestState.error;
    AppNotify.error(T.errorGeneric.tr, message: message);
  }
}
