import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/core/services/xp_grant_handler.dart';
import 'package:englishme/modules/learn/controllers/curriculum_progress_bus.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum LessonPhase { theory, practice, quiz, summary, extraPractice }

class LessonPlayerController extends GetxController {
  LessonPlayerController(this._repo);
  final CurriculumRepository _repo;

  final loading = true.obs;
  final detail = Rxn<CurriculumLessonDetail>();
  final phase = LessonPhase.theory.obs;

  /// Chế độ ÔN TẬP: bài đã hoàn thành (đã nộp) → cho xem & đi tự do qua lại mọi
  /// bước, không reset đáp án. Khác chế độ làm bài (chỉ lùi, lùi thì reset).
  final reviewMode = false.obs;

  // practice — input state cho từng dạng bài
  final practiceIndex = 0.obs;
  final practiceSelected = Rxn<String>(); // multiple_choice | listening_choice → optionId
  final practiceText = ''.obs; // grammar_fill_blank | translation | error_correction → text nhập
  final RxMap<String, String> practiceMatch = <String, String>{}.obs; // vocabulary_match → left→right
  final RxList<int> practiceOrder = <int>[].obs; // sentence_ordering → thứ tự token đã chọn
  final practicePronounced = false.obs; // pronunciation → đã "ghi âm" xong chưa
  final practiceAnswered = false.obs;
  final RxList<String> retryQueue = <String>[].obs;

  // quiz — input state cho từng dạng bài
  final quizIndex = 0.obs;
  final quizSelected = Rxn<String>(); // multiple_choice | listening_choice → optionId
  final quizText = ''.obs; // grammar_fill_blank | translation | error_correction → text nhập
  final RxList<int> quizOrder = <int>[].obs; // sentence_ordering → thứ tự token đã chọn
  final RxMap<String, String> quizMatch = <String, String>{}.obs; // vocabulary_match → left→right
  final quizPronounced = false.obs; // pronunciation → đã "ghi âm" xong chưa
  // Đáp án THÔ tích luỹ để gửi BE chấm (không tự chấm ở client nữa).
  final List<Map<String, dynamic>> _quizAnswers = [];
  // Đáp án THÔ practice theo activityId (ghi đè khi làm lại) → gửi BE đánh dấu
  // practice_completed khi xong luyện tập.
  final Map<String, Map<String, dynamic>> _practiceAnswers = {};

  // result
  final result = Rxn<LessonResult>();
  String lessonId = '';

  // ── Luyện tập THÊM (AI gen) — tách biệt practice/quiz gốc, KHÔNG tính XP/mastery ──
  final extraQuestions = <CurriculumActivity>[].obs;
  final extraIndex = 0.obs;
  final extraSelected = Rxn<String>();
  final extraAnswered = false.obs;
  final extraCorrectCount = 0.obs;
  final isGeneratingExtra = false.obs;
  final extraFinished = false.obs; // làm hết câu → hiện điểm
  // Text mọi câu đã gen trong phiên để lần gen sau tránh trùng.
  final List<String> _generatedQuestionTexts = [];

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map && arg['lessonId'] != null) lessonId = arg['lessonId'].toString();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final d = await _repo.getLessonDetail(lessonId);
      detail.value = d;
      // Tiến độ lấy từ SERVER (bền, đồng bộ đa thiết bị) — không lưu ở client.
      if (d.isCompleted) {
        // Đã hoàn thành (đã nộp ≥1 lần) → vào THẲNG màn Kết quả với điểm cũ
        // (server trả bestScore + unitProgress). Vẫn ở reviewMode để bấm stepper
        // lùi xem lại lý thuyết/bài tập tự do. result==null trước đây → fallback
        // "đã hoàn thành" trống; giờ dựng lại LessonResult từ điểm đã lưu.
        reviewMode.value = true;
        result.value = LessonResult(
          passed: d.bestScore >= d.requiredScoreToPass,
          score: d.bestScore,
          xpEarned: 0, // XP đã cộng lần nộp gốc — không cộng lại khi xem.
          unitProgress: d.unitProgress,
          unitCompleted: d.unitCompleted,
          nextLessonId: d.nextLessonId, // còn bài kế → nút "Bài tiếp theo".
        );
        phase.value = LessonPhase.summary;
      } else if (d.practiceCompleted) {
        // Đã xong luyện tập nhưng chưa nộp quiz → vào thẳng Kiểm tra.
        phase.value = LessonPhase.quiz;
      } else if (d.theoryViewed) {
        phase.value = LessonPhase.practice;
      } else {
        phase.value = LessonPhase.theory;
      }
    } finally {
      loading.value = false;
    }
  }

  // ── Điều hướng qua lại giữa các bước (bấm chấm trên stepper) ──
  /// Chế độ ÔN TẬP (bài đã hoàn thành): đi tự do mọi hướng, KHÔNG reset đáp án.
  /// Chế độ làm bài: chỉ cho LÙI về theory/practice và reset input từ đó trở đi
  /// để làm lại từ đầu — tránh lẫn đáp án cũ và gửi BE đáp án quiz nửa chừng.
  void goToPhase(LessonPhase target) {
    if (target == phase.value) return;

    if (reviewMode.value) {
      // Ôn tập: nhảy đâu cũng được, chỉ để xem lại, không động vào đáp án.
      phase.value = target;
      return;
    }

    // Chỉ cho phép lùi (về bước trước), không cho nhảy tới.
    if (target.index >= phase.value.index) return;
    // Đã nộp bài (có kết quả) thì khoá, không cho lùi nữa.
    if (phase.value == LessonPhase.summary) return;

    if (target == LessonPhase.theory) {
      _resetPractice();
      _resetQuiz();
    } else if (target == LessonPhase.practice) {
      // Lùi từ quiz về practice → làm lại luyện tập + quiz từ đầu.
      _resetPractice();
      _resetQuiz();
    }
    phase.value = target;
  }

  void _resetPractice() {
    practiceIndex.value = 0;
    practiceAnswered.value = false;
    practiceSelected.value = null;
    practiceText.value = '';
    practiceMatch.clear();
    practiceOrder.clear();
    practicePronounced.value = false;
    retryQueue.clear();
    _practiceAnswers.clear();
  }

  void _resetQuiz() {
    quizIndex.value = 0;
    quizSelected.value = null;
    quizText.value = '';
    quizOrder.clear();
    quizMatch.clear();
    quizPronounced.value = false;
    _quizAnswers.clear();
  }

  // ── Giai đoạn 1: Lý thuyết ──
  Future<void> completeTheory() async {
    // Ôn tập: chỉ chuyển bước để xem tiếp, không gọi BE / không ghi tiến độ.
    if (reviewMode.value) {
      phase.value = LessonPhase.practice;
      return;
    }
    await _repo.completeTheory(lessonId);
    CurriculumProgressBus.markDirty();
    phase.value = LessonPhase.practice;
  }

  // ── Chấm điểm chung cho mọi dạng bài (local, tại chỗ) ──
  bool _isCorrect(
    CurriculumActivity a, {
    String? optionId,
    String text = '',
    Map<String, String> match = const {},
    List<int> order = const [],
    bool pronounced = false,
  }) {
    // fill_blank | translation | error_correction → so text với acceptedAnswers
    if (a.isTextInput) {
      final ans = _norm(text);
      if (ans.isEmpty) return false;
      return a.acceptedAnswers.any((e) => _norm(e) == ans);
    }
    if (a.isMatch) {
      if (a.pairs.isEmpty) return false;
      return a.pairs.every((p) => match[p.left] == p.right);
    }
    if (a.isOrdering) {
      if (a.correctOrder.isEmpty || order.length != a.correctOrder.length) {
        return false;
      }
      for (var i = 0; i < order.length; i++) {
        if (order[i] != a.correctOrder[i]) return false;
      }
      return true;
    }
    if (a.isPronunciation) {
      // Mock: coi như đạt khi đã ghi âm (BE thật sẽ chấm Levenshtein server-side).
      return pronounced;
    }
    // multiple_choice | listening_choice → so optionId
    return optionId != null && optionId == a.correctOptionId;
  }

  String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  // ── Giai đoạn 2: Luyện tập (feedback tức thì) ──
  CurriculumActivity? get currentPractice {
    final list = detail.value?.exercises ?? [];
    if (practiceIndex.value >= list.length) return null;
    return list[practiceIndex.value];
  }

  /// Đã nhập đủ để bấm "Kiểm tra" chưa (tuỳ dạng bài).
  bool get canCheckPractice {
    final a = currentPractice;
    if (a == null) return false;
    if (a.isTextInput) return practiceText.value.trim().isNotEmpty;
    if (a.isMatch) return practiceMatch.length == a.pairs.length;
    if (a.isOrdering) return practiceOrder.length == a.tokens.length;
    if (a.isPronunciation) return practicePronounced.value;
    return practiceSelected.value != null;
  }

  /// Kết quả đúng/sai của câu practice hiện tại (dùng để tô màu feedback).
  bool get practiceIsCorrect {
    final a = currentPractice;
    if (a == null) return false;
    return _isCorrect(
      a,
      optionId: practiceSelected.value,
      text: practiceText.value,
      match: practiceMatch,
      order: practiceOrder,
      pronounced: practicePronounced.value,
    );
  }

  void selectPractice(String optionId) {
    if (practiceAnswered.value) return;
    practiceSelected.value = optionId;
  }

  void typePractice(String text) {
    if (practiceAnswered.value) return;
    practiceText.value = text;
  }

  void matchPractice(String left, String right) {
    if (practiceAnswered.value) return;
    practiceMatch[left] = right;
  }

  /// sentence_ordering: thêm/bớt token (theo index trong tokens gốc).
  void toggleOrderPractice(int tokenIndex) {
    if (practiceAnswered.value) return;
    if (practiceOrder.contains(tokenIndex)) {
      practiceOrder.remove(tokenIndex);
    } else {
      practiceOrder.add(tokenIndex);
    }
  }

  void resetOrderPractice() {
    if (practiceAnswered.value) return;
    practiceOrder.clear();
  }

  /// pronunciation: đánh dấu đã "ghi âm" xong (mock — không thu âm thật).
  void markPronouncedPractice() {
    if (practiceAnswered.value) return;
    practicePronounced.value = true;
  }

  void checkPractice() {
    final a = currentPractice;
    if (a == null || !canCheckPractice) return;
    practiceAnswered.value = true;
    // Lưu đáp án thô câu này (ghi đè nếu làm lại) để gửi BE khi xong luyện tập.
    _practiceAnswers[a.id] = _rawAnswer(
      a,
      optionId: practiceSelected.value,
      text: practiceText.value,
      match: practiceMatch,
      order: practiceOrder,
      pronounced: practicePronounced.value,
    );
    final isCorrect = practiceIsCorrect;
    if (!isCorrect && !retryQueue.contains(a.id)) {
      retryQueue.add(a.id); // sai → đưa vào hàng đợi làm lại
    } else if (isCorrect) {
      retryQueue.remove(a.id);
    }
    SoundService.to.play(isCorrect ? AppSound.correct : AppSound.wrong);
  }

  Future<void> nextPractice() async {
    final list = detail.value?.exercises ?? [];
    practiceAnswered.value = false;
    practiceSelected.value = null;
    practiceText.value = '';
    practiceMatch.clear();
    practiceOrder.clear();
    practicePronounced.value = false;
    if (practiceIndex.value < list.length - 1) {
      practiceIndex.value++;
    } else if (retryQueue.isNotEmpty) {
      // quay lại câu sai đầu tiên
      practiceIndex.value =
          list.indexWhere((e) => e.id == retryQueue.first);
    } else {
      phase.value = LessonPhase.quiz; // hết câu + không còn câu sai → vào quiz
      // Đang làm bài → báo BE đã xong luyện tập (lưu bền practice_completed,
      // lần sau vào thẳng quiz). Ôn tập thì không gửi lại.
      if (!reviewMode.value) {
        await _repo.submitExercises(
          lessonId,
          _practiceAnswers.values.toList(),
        );
        CurriculumProgressBus.markDirty();
      }
    }
  }

  // ── Giai đoạn 3: Mini-quiz (không feedback giữa chừng) ──
  CurriculumActivity? get currentQuiz {
    final list = detail.value?.quiz ?? [];
    if (quizIndex.value >= list.length) return null;
    return list[quizIndex.value];
  }

  /// Đã trả lời câu quiz hiện tại chưa (để bật nút "Câu tiếp/Nộp").
  bool get canSubmitQuiz {
    final a = currentQuiz;
    if (a == null) return false;
    if (a.isTextInput) return quizText.value.trim().isNotEmpty;
    if (a.isOrdering) return quizOrder.length == a.tokens.length;
    if (a.isMatch) return quizMatch.length == a.pairs.length;
    if (a.isPronunciation) return quizPronounced.value;
    return quizSelected.value != null;
  }

  void selectQuiz(String optionId) => quizSelected.value = optionId;

  void typeQuiz(String text) => quizText.value = text;

  void matchQuiz(String left, String right) => quizMatch[left] = right;

  void markPronouncedQuiz() => quizPronounced.value = true;

  void toggleOrderQuiz(int tokenIndex) {
    if (quizOrder.contains(tokenIndex)) {
      quizOrder.remove(tokenIndex);
    } else {
      quizOrder.add(tokenIndex);
    }
  }

  void resetOrderQuiz() => quizOrder.clear();

  /// Gom đáp án THÔ của câu quiz hiện tại (không tự chấm — BE sẽ chấm).
  Map<String, dynamic> _rawQuizAnswer(CurriculumActivity a) => _rawAnswer(
        a,
        optionId: quizSelected.value,
        text: quizText.value,
        match: quizMatch,
        order: quizOrder,
        pronounced: quizPronounced.value,
      );

  /// Gom đáp án THÔ chung theo dạng bài (dùng cho cả practice & quiz).
  Map<String, dynamic> _rawAnswer(
    CurriculumActivity a, {
    String? optionId,
    String text = '',
    Map<String, String> match = const {},
    List<int> order = const [],
    bool pronounced = false,
  }) {
    final m = <String, dynamic>{'activityId': a.id};
    if (a.isTextInput) {
      m['text'] = text;
    } else if (a.isOrdering) {
      m['order'] = List<int>.from(order);
    } else if (a.isMatch) {
      m['match'] = Map<String, String>.from(match);
    } else if (a.isPronunciation) {
      m['pronounced'] = pronounced;
    } else {
      // multiple_choice | listening_choice
      m['selectedOptionId'] = optionId;
    }
    return m;
  }

  Future<void> nextQuiz() async {
    final list = detail.value?.quiz ?? [];
    final a = currentQuiz;
    if (a != null) {
      _quizAnswers.add(_rawQuizAnswer(a)); // tích luỹ, gửi BE chấm khi nộp
    }
    quizSelected.value = null;
    quizText.value = '';
    quizOrder.clear();
    quizMatch.clear();
    quizPronounced.value = false;
    if (quizIndex.value < list.length - 1) {
      quizIndex.value++;
    } else if (reviewMode.value) {
      // Ôn tập: không nộp lại (không gọi BE, không ghi đè điểm) — chỉ sang
      // trang Kết quả để xem trạng thái "đã hoàn thành".
      _quizAnswers.clear();
      quizIndex.value = 0;
      phase.value = LessonPhase.summary;
    } else {
      // Nộp toàn bộ đáp án thô → BE tự chấm điểm mastery + lưu status=completed.
      // Lần sau getLessonDetail trả status='completed' → tự vào chế độ ôn tập.
      final res = await _repo.completeLesson(lessonId, _quizAnswers);
      result.value = res;
      CurriculumProgressBus.markDirty();
      // Đồng bộ XP (Profile/Home/Progress) + ăn mừng bonus đạt mục tiêu ngày.
      // Trước đây luồng giáo trình KHÔNG gọi handler → Home phải load tay.
      XpGrantHandler.apply(
        totalXp: res.totalXp,
        xpEarned: res.xpEarned,
        streakUpdated: res.streakUpdated,
        bonuses: res.bonuses,
        newBadges: res.newBadges,
      );
      phase.value = LessonPhase.summary;
    }
  }

  // ── Điều hướng từ màn Kết quả ──
  /// Làm lại bài hiện tại từ đầu (dùng khi CHƯA ĐẠT) — reset sạch input,
  /// thoát chế độ ôn tập, đưa về luyện tập (lý thuyết đã xem rồi).
  void retryLesson() {
    _resetPractice();
    _resetQuiz();
    result.value = null;
    reviewMode.value = false;
    phase.value =
        (detail.value?.theoryViewed ?? false) ? LessonPhase.practice : LessonPhase.theory;
  }

  /// Mở bài học kế tiếp (nếu BE trả nextLessonId). Vì binding dùng fenix, route
  /// cùng tên KHÔNG tạo lại controller (onInit không chạy lại) → nạp ngay trong
  /// controller hiện tại: đổi lessonId, reset state, load() lại từ server.
  Future<void> goToNextLesson() async {
    final next = result.value?.nextLessonId;
    if (next == null || next.isEmpty) {
      Get.back();
      return;
    }
    lessonId = next;
    reviewMode.value = false;
    result.value = null;
    _resetPractice();
    _resetQuiz();
    phase.value = LessonPhase.theory;
    await load();
  }

  /// Về danh sách Unit của level hiện tại (dùng khi đã hết bài trong unit) để
  /// người học tự chọn unit kế. offNamed → back không quay lại màn Kết quả.
  void goToUnitList() {
    final level = detail.value?.level ?? '';
    if (level.isEmpty) {
      Get.back();
      return;
    }
    Get.offNamed(AppRoutes.curriculumUnits, arguments: {'level': level});
  }

  // ── Luyện tập THÊM với AI ──
  /// Gọi BE sinh 5 câu MCQ mới từ lý thuyết bài. Tránh trùng câu sẵn có + đã gen.
  Future<void> startExtraPractice() async {
    if (isGeneratingExtra.value) return;
    final d = detail.value;
    if (d == null) return;

    isGeneratingExtra.value = true;
    try {
      final existing = <String>[
        ...d.exercises.map((e) => e.question),
        ...d.quiz.map((e) => e.question),
        ..._generatedQuestionTexts,
      ].where((q) => q.trim().isNotEmpty).toList();

      final questions = await _repo.generateExtraPractice(lessonId, existing);
      if (questions.isEmpty) {
        AppNotify.warning('Luyện tập thêm', message: 'Chưa tạo được câu hỏi. Vui lòng thử lại.');
        return;
      }
      _generatedQuestionTexts.addAll(questions.map((q) => q.question));
      extraQuestions.assignAll(questions);
      extraIndex.value = 0;
      extraSelected.value = null;
      extraAnswered.value = false;
      extraCorrectCount.value = 0;
      extraFinished.value = false;
      phase.value = LessonPhase.extraPractice;
    } catch (_) {
      AppNotify.error('Luyện tập thêm', message: 'Có lỗi khi tạo câu hỏi. Vui lòng thử lại.');
    } finally {
      isGeneratingExtra.value = false;
    }
  }

  /// Gen tiếp 5 câu nữa (khác câu đã làm) sau khi xong một lượt.
  Future<void> generateMoreExtra() => startExtraPractice();

  CurriculumActivity? get currentExtra {
    if (extraIndex.value >= extraQuestions.length) return null;
    return extraQuestions[extraIndex.value];
  }

  int get extraScore => extraQuestions.isEmpty
      ? 0
      : ((extraCorrectCount.value / extraQuestions.length) * 100).round();

  bool get extraIsCorrect {
    final a = currentExtra;
    return a != null && extraSelected.value == a.correctOptionId;
  }

  void selectExtra(String optionId) {
    if (extraAnswered.value) return;
    extraSelected.value = optionId;
  }

  void checkExtra() {
    final a = currentExtra;
    if (a == null || extraSelected.value == null || extraAnswered.value) return;
    extraAnswered.value = true;
    final correct = extraIsCorrect;
    if (correct) extraCorrectCount.value++;
    SoundService.to.play(correct ? AppSound.correct : AppSound.wrong);
  }

  void nextExtra() {
    extraAnswered.value = false;
    extraSelected.value = null;
    if (extraIndex.value < extraQuestions.length - 1) {
      extraIndex.value++;
    } else {
      extraFinished.value = true; // hết câu → hiện điểm
    }
  }

  // ── Luyện thêm bằng 4 ENGINE KỸ NĂNG (B xoay quanh A) ────────────────────
  /// Kỹ năng của bài → có engine luyện chuyên sâu tương ứng không.
  /// (grammar/vocabulary luyện ngay trong lesson, không có engine riêng.)
  bool get hasSkillEngine {
    final skill = detail.value?.skill ?? '';
    return skill == 'listening' ||
        skill == 'speaking' ||
        skill == 'reading' ||
        skill == 'writing';
  }

  /// Nhãn nút "Luyện thêm" theo kỹ năng của bài.
  String get skillEngineLabel {
    switch (detail.value?.skill) {
      case 'listening':
        return 'Luyện nghe chép câu trong bài';
      case 'speaking':
        return 'Luyện nói chủ đề bài này';
      case 'reading':
        return 'Luyện đọc hiểu cùng cấp';
      case 'writing':
        return 'Viết theo chủ đề bài này';
      default:
        return 'Luyện thêm kỹ năng';
    }
  }

  /// Mở engine kỹ năng tương ứng, truyền lessonId + level để luyện ĐÚNG nội dung
  /// vừa học. Dictation/Writing nhận lessonId (câu/đề bám bài); Conversation nhận
  /// topic = tiêu đề bài; Reading theo level (kho reading không gắn theo lesson).
  void openSkillEngine() {
    final d = detail.value;
    if (d == null) return;
    final level = d.level;
    switch (d.skill) {
      case 'listening':
        Get.toNamed(AppRoutes.dictation,
            arguments: {'level': level, 'lessonId': d.id});
      case 'speaking':
        Get.toNamed(AppRoutes.conversation, arguments: {'topic': d.title});
      case 'reading':
        Get.toNamed(AppRoutes.exerciseQuiz,
            arguments: {'category': 'reading', 'level': level});
      case 'writing':
        Get.toNamed(AppRoutes.writing,
            arguments: {'level': level, 'lessonId': d.id});
    }
  }

  /// Thoát luyện thêm, về màn Kết quả gốc.
  void exitExtraPractice() {
    extraQuestions.clear();
    extraIndex.value = 0;
    extraSelected.value = null;
    extraAnswered.value = false;
    extraCorrectCount.value = 0;
    extraFinished.value = false;
    phase.value = LessonPhase.summary;
  }
}
