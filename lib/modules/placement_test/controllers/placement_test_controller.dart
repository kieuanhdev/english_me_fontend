import 'dart:async';

import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';

import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/placement_test/models/placement_test_models.dart';
import 'package:englishme/modules/placement_test/repositories/placement_test_repository.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/routes/app_routes.dart';

enum PlacementTestState { idle, loading, questioning, submitting, completed, error }

/// Placement Test theo mô hình CAT (Computerized Adaptive Testing).
///
/// Khác bản cũ (đề cố định 16 câu): mỗi lần [submitAnswer] backend trả câu kế tiếp
/// dựa trên ability estimate θ. Client không biết trước danh sách câu.
class PlacementTestController extends GetxController {
  final PlacementTestRepository _repository;

  PlacementTestController(this._repository);

  final state = PlacementTestState.idle.obs;

  /// Câu hỏi đang hiển thị (CAT trả từng câu một).
  final currentQuestion = Rxn<QuestionModel>();

  final selectedAnswer = Rxn<String>();
  final answerResponse = Rxn<CatAnswerResponseModel>();
  final testResult = Rxn<TestResultModel>();
  final errorMessage = ''.obs;

  /// Tiến độ phiên: số câu đã trả lời / tối đa.
  final answeredCount = 0.obs;
  final maxQuestions = 15.obs;

  /// Các câu ĐÃ làm — giữ để map questionId → skillCategory cho màn kết quả.
  final answeredQuestions = <QuestionModel>[].obs;

  /// Thông báo từ backend (bài đầu vào xác định A1–C1).
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

  double get progress =>
      maxQuestions.value == 0 ? 0 : answeredCount.value / maxQuestions.value;

  bool get isAnswered => answerResponse.value != null;

  Future<void> startTest() async {
    try {
      state.value = PlacementTestState.loading;
      final response = await _repository.startTest();
      _sessionId = response.sessionId;
      notice.value = response.notice;
      maxQuestions.value = response.maxQuestions;
      answeredCount.value = 0;
      answeredQuestions.clear();
      _completing = false;
      currentQuestion.value = response.firstQuestion;
      if (response.firstQuestion != null) {
        answeredQuestions.add(response.firstQuestion!);
      }
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
    final question = currentQuestion.value;
    if (answer == null || question == null) return;

    try {
      state.value = PlacementTestState.submitting;
      final response = await _repository.answerQuestion(
        _sessionId,
        question.id,
        answer,
      );
      answerResponse.value = response;
      answeredCount.value = response.answeredCount;
      state.value = PlacementTestState.questioning;
    } catch (_) {
      state.value = PlacementTestState.questioning;
      AppNotify.error(T.errorGeneric.tr, message: T.errorSubmitAnswer.tr);
    }
  }

  /// Sang câu kế tiếp (CAT) hoặc hoàn thành nếu backend báo isDone.
  Future<void> nextQuestion() async {
    if (state.value == PlacementTestState.loading ||
        state.value == PlacementTestState.completed) {
      return;
    }
    final response = answerResponse.value;
    if (response == null) return;

    if (response.isDone || response.nextQuestion == null) {
      state.value = PlacementTestState.loading;
      await _completeTest();
      return;
    }

    final next = response.nextQuestion!;
    currentQuestion.value = next;
    answeredQuestions.add(next);
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
