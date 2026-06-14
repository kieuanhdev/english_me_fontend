abstract class AppRoutes {
  static const splash = '/splash';
  static const shell = '/shell';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const learn = '/learn';
  static const curriculumUnits = '/learn/curriculum/units';
  static const curriculumUnitDetail = '/learn/curriculum/unit';
  static const curriculumLessonPlayer = '/learn/curriculum/lesson';
  static const curriculumCheckpoint = '/learn/curriculum/checkpoint';
  static const flashcards = '/learn/flashcards';
  static const grammarTheory = '/learn/grammar/theory';
  static const grammarLessonDetail = '/learn/grammar/lesson';
  static const pronunciation = '/learn/pronunciation';
  static const pronunciationPractice = '/learn/pronunciation/practice';
  static const pronunciationResult = '/learn/pronunciation/result';
  static const ipa = '/learn/pronunciation/ipa';
  static const pronunciationInsight = '/learn/pronunciation/insight';
  static const conversation = '/learn/pronunciation/conversation';
  static const conversationChat = '/learn/pronunciation/conversation/chat';
  static const conversationSummary =
      '/learn/pronunciation/conversation/summary';
  static const deckPrep = '/learn/flashcards/deck-prep';
  static const addFlashcard = '/learn/flashcards/add-card';
  static const createDeck = '/learn/flashcards/create-deck';
  static const exercise = '/exercise';
  static const exerciseQuiz = '/exercise/quiz';
  static const exerciseResult = '/exercise/result';
  static const test = '/test';
  static const testQuestion = '/test/question';
  static const testResult = '/test/result';
  static const placementTest = '/placement-test';
  static const placementTestQuestion = '/placement-test/question';
  static const placementTestResult = '/placement-test/result';
  static const placementLevelPicker = '/placement-test/self-select';
  static const studySession = '/study-session';
  static const studySessionCardBack = '/study-session/card-back';
  static const sessionSummary = '/study-session/summary';
  static const progress = '/progress';
  static const profile = '/profile';

  // VocabHub (flashcard / deck)
  static const vocabHub = '/learn/vocab';

  // Kỹ năng cần cải thiện (cá nhân hóa: yếu skill gì + yếu ở đâu + luyện ngay)
  static const weakSkills = '/learn/weak-skills';

  /// Tập hợp mọi route hợp lệ — dùng để validate route do backend trả về
  /// (notification.actionRoute, learningPath.route) trước khi `Get.toNamed`.
  /// Backend trả route lạ → bỏ qua điều hướng thay vì văng màn trắng.
  static const Set<String> all = {
    splash,
    shell,
    welcome,
    login,
    register,
    home,
    learn,
    curriculumUnits,
    curriculumUnitDetail,
    curriculumLessonPlayer,
    curriculumCheckpoint,
    flashcards,
    grammarTheory,
    grammarLessonDetail,
    pronunciation,
    pronunciationPractice,
    pronunciationResult,
    ipa,
    pronunciationInsight,
    conversation,
    conversationChat,
    conversationSummary,
    deckPrep,
    addFlashcard,
    createDeck,
    exercise,
    exerciseQuiz,
    exerciseResult,
    test,
    testQuestion,
    testResult,
    placementTest,
    placementTestQuestion,
    placementTestResult,
    placementLevelPicker,
    studySession,
    studySessionCardBack,
    sessionSummary,
    progress,
    profile,
    vocabHub,
    weakSkills,
  };

  /// `true` nếu [route] là một route đã đăng ký (so khớp chính xác, bỏ khoảng trắng).
  static bool isKnown(String? route) =>
      route != null && all.contains(route.trim());
}
