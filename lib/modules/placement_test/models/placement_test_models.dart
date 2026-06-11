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

  const QuestionModel({
    required this.id,
    required this.cefrLevel,
    required this.skillCategory,
    required this.question,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json['id'] as String? ?? '',
    cefrLevel: json['cefrLevel'] as String? ?? '',
    skillCategory: json['skillCategory'] as String? ?? '',
    question: json['question'] as String? ?? '',
    options: (json['options'] is Map)
        ? (json['options'] as Map).map((k, v) => MapEntry('$k', '$v'))
        : const <String, String>{},
  );

  List<QuestionOptionModel> get optionList =>
      options.entries.map((e) => QuestionOptionModel(id: e.key, text: e.value)).toList();
}

class StartTestResponse {
  final String sessionId;
  final int totalQuestions;
  final List<QuestionModel> questions;

  /// Thông báo giới hạn: bài đầu vào chỉ xác định trình độ tối đa tới B2.
  final String notice;

  const StartTestResponse({
    required this.sessionId,
    required this.totalQuestions,
    required this.questions,
    this.notice = '',
  });

  factory StartTestResponse.fromJson(Map<String, dynamic> json) => StartTestResponse(
    sessionId: json['sessionId'] as String? ?? '',
    totalQuestions: json['totalQuestions'] as int? ?? 0,
    questions: ((json['questions'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(QuestionModel.fromJson)
        .toList(),
    notice: json['notice'] as String? ?? '',
  );
}

class AnswerResponseModel {
  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;
  final int answeredCount;
  final int totalQuestions;

  const AnswerResponseModel({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
    required this.answeredCount,
    required this.totalQuestions,
  });

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) => AnswerResponseModel(
    questionId: json['questionId'] as String? ?? '',
    selectedAnswer: json['selectedAnswer'] as String? ?? '',
    correctAnswer: json['correctAnswer'] as String? ?? '',
    isCorrect: (json['isCorrect'] ?? json['correct'] ?? false) as bool,
    explanation: json['explanation'] as String? ?? '',
    answeredCount: json['answeredCount'] as int? ?? 0,
    totalQuestions: json['totalQuestions'] as int? ?? 0,
  );
}

class ReviewItemModel {
  final String questionId;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  const ReviewItemModel({
    required this.questionId,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  factory ReviewItemModel.fromJson(Map<String, dynamic> json) => ReviewItemModel(
    questionId: json['questionId'] as String? ?? '',
    question: json['question'] as String? ?? '',
    selectedAnswer: json['selectedAnswer'] as String? ?? '',
    correctAnswer: json['correctAnswer'] as String? ?? '',
    isCorrect: (json['isCorrect'] ?? json['correct'] ?? false) as bool,
    explanation: json['explanation'] as String? ?? '',
  );
}

class TestResultModel {
  final String sessionId;
  final String resultLevel;
  final int score;
  final int totalQuestions;
  final List<ReviewItemModel> review;

  /// Học viên đã kịch trần B2 và có dấu hiệu giỏi hơn B2 (chỉ là tín hiệu UI).
  final bool canGoHigherThanB2;

  /// Thông báo gợi ý làm bài kiểm tra lên cấp (rỗng nếu [canGoHigherThanB2] false).
  final String aboveLevelMessage;

  const TestResultModel({
    required this.sessionId,
    required this.resultLevel,
    required this.score,
    required this.totalQuestions,
    required this.review,
    this.canGoHigherThanB2 = false,
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
    canGoHigherThanB2: (json['canGoHigherThanB2'] ?? false) as bool,
    aboveLevelMessage: json['aboveLevelMessage'] as String? ?? '',
  );
}
