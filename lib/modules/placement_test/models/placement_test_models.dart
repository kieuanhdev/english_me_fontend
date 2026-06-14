class QuestionOptionModel {
  final String id;
  final String text;

  const QuestionOptionModel({required this.id, required this.text});
}

class QuestionModel {
  final String id;
  final String cefrLevel;
  final String skillCategory;
  final String question;
  final Map<String, String> options;

  /// Đoạn văn cho câu reading (rỗng với grammar/vocabulary).
  final String passage;

  const QuestionModel({
    required this.id,
    required this.cefrLevel,
    required this.skillCategory,
    required this.question,
    required this.options,
    this.passage = '',
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json['id'] as String? ?? '',
    cefrLevel: json['cefrLevel'] as String? ?? '',
    skillCategory: json['skillCategory'] as String? ?? '',
    question: json['question'] as String? ?? '',
    options: (json['options'] is Map)
        ? (json['options'] as Map).map((k, v) => MapEntry('$k', '$v'))
        : const <String, String>{},
    passage: json['passage'] as String? ?? '',
  );

  List<QuestionOptionModel> get optionList =>
      options.entries.map((e) => QuestionOptionModel(id: e.key, text: e.value)).toList();
}

/// Phản hồi khi bắt đầu phiên CAT: chỉ có câu hỏi ĐẦU TIÊN (1 câu).
class StartTestResponse {
  final String sessionId;
  final int maxQuestions;
  final QuestionModel? firstQuestion;

  /// Thông báo giới hạn: bài đầu vào xác định trình độ A1–C1.
  final String notice;

  const StartTestResponse({
    required this.sessionId,
    required this.maxQuestions,
    required this.firstQuestion,
    this.notice = '',
  });

  factory StartTestResponse.fromJson(Map<String, dynamic> json) => StartTestResponse(
    sessionId: json['sessionId'] as String? ?? '',
    maxQuestions: json['maxQuestions'] as int? ?? 15,
    firstQuestion: json['firstQuestion'] is Map<String, dynamic>
        ? QuestionModel.fromJson(json['firstQuestion'] as Map<String, dynamic>)
        : null,
    notice: json['notice'] as String? ?? '',
  );
}

/// Phản hồi sau mỗi câu trả lời trong CAT: feedback + câu kế tiếp (hoặc isDone).
class CatAnswerResponseModel {
  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;
  final int answeredCount;
  final int maxQuestions;
  final bool isDone;
  final QuestionModel? nextQuestion;

  const CatAnswerResponseModel({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
    required this.answeredCount,
    required this.maxQuestions,
    required this.isDone,
    required this.nextQuestion,
  });

  factory CatAnswerResponseModel.fromJson(Map<String, dynamic> json) => CatAnswerResponseModel(
    questionId: json['questionId'] as String? ?? '',
    selectedAnswer: json['selectedAnswer'] as String? ?? '',
    correctAnswer: json['correctAnswer'] as String? ?? '',
    isCorrect: (json['isCorrect'] ?? json['correct'] ?? false) as bool,
    explanation: json['explanation'] as String? ?? '',
    answeredCount: json['answeredCount'] as int? ?? 0,
    maxQuestions: json['maxQuestions'] as int? ?? 15,
    isDone: (json['isDone'] ?? json['done'] ?? false) as bool,
    nextQuestion: json['nextQuestion'] is Map<String, dynamic>
        ? QuestionModel.fromJson(json['nextQuestion'] as Map<String, dynamic>)
        : null,
  );
}

class ReviewItemModel {
  final String questionId;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;
  final String skillCategory;

  const ReviewItemModel({
    required this.questionId,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
    this.skillCategory = '',
  });

  factory ReviewItemModel.fromJson(Map<String, dynamic> json) => ReviewItemModel(
    questionId: json['questionId'] as String? ?? '',
    question: json['question'] as String? ?? '',
    selectedAnswer: json['selectedAnswer'] as String? ?? '',
    correctAnswer: json['correctAnswer'] as String? ?? '',
    isCorrect: (json['isCorrect'] ?? json['correct'] ?? false) as bool,
    explanation: json['explanation'] as String? ?? '',
    skillCategory: json['skillCategory'] as String? ?? '',
  );
}

class TestResultModel {
  final String sessionId;
  final String resultLevel;
  final int score;
  final int totalQuestions;
  final List<ReviewItemModel> review;

  /// Ability estimate cuối của phiên CAT (IRT 1PL θ).
  final double finalTheta;

  /// Học viên đã kịch trần C1 và có dấu hiệu giỏi hơn (gợi ý C2) — tín hiệu UI.
  final bool canGoHigherThanC1;

  /// Thông báo gợi ý làm bài kiểm tra lên cấp (rỗng nếu [canGoHigherThanC1] false).
  final String aboveLevelMessage;

  const TestResultModel({
    required this.sessionId,
    required this.resultLevel,
    required this.score,
    required this.totalQuestions,
    required this.review,
    this.finalTheta = 0.0,
    this.canGoHigherThanC1 = false,
    this.aboveLevelMessage = '',
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) => TestResultModel(
    sessionId: json['sessionId'] as String? ?? '',
    resultLevel: json['resultLevel'] as String? ?? '',
    score: json['score'] as int? ?? 0,
    totalQuestions: json['totalQuestions'] as int? ?? 0,
    review: ((json['review'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReviewItemModel.fromJson)
        .toList(),
    finalTheta: (json['finalTheta'] as num?)?.toDouble() ?? 0.0,
    canGoHigherThanC1: (json['canGoHigherThanC1'] ?? false) as bool,
    aboveLevelMessage: json['aboveLevelMessage'] as String? ?? '',
  );
}
