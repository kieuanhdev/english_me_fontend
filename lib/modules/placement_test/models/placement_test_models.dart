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
    id: json['id'],
    cefrLevel: json['cefrLevel'] ?? '',
    skillCategory: json['skillCategory'] ?? '',
    question: json['question'],
    options: Map<String, String>.from(json['options'] as Map),
  );

  List<QuestionOptionModel> get optionList =>
      options.entries.map((e) => QuestionOptionModel(id: e.key, text: e.value)).toList();
}

class StartTestResponse {
  final String sessionId;
  final int totalQuestions;
  final List<QuestionModel> questions;

  const StartTestResponse({
    required this.sessionId,
    required this.totalQuestions,
    required this.questions,
  });

  factory StartTestResponse.fromJson(Map<String, dynamic> json) => StartTestResponse(
    sessionId: json['sessionId'],
    totalQuestions: json['totalQuestions'],
    questions: (json['questions'] as List).map((q) => QuestionModel.fromJson(q)).toList(),
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
    questionId: json['questionId'],
    selectedAnswer: json['selectedAnswer'],
    correctAnswer: json['correctAnswer'],
    isCorrect: json['isCorrect'] ?? json['correct'] ?? false,
    explanation: json['explanation'] ?? '',
    answeredCount: json['answeredCount'],
    totalQuestions: json['totalQuestions'],
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
    questionId: json['questionId'],
    question: json['question'],
    selectedAnswer: json['selectedAnswer'],
    correctAnswer: json['correctAnswer'],
    isCorrect: json['isCorrect'] ?? json['correct'] ?? false,
    explanation: json['explanation'] ?? '',
  );
}

class TestResultModel {
  final String sessionId;
  final String resultLevel;
  final int score;
  final int totalQuestions;
  final List<ReviewItemModel> review;

  const TestResultModel({
    required this.sessionId,
    required this.resultLevel,
    required this.score,
    required this.totalQuestions,
    required this.review,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) => TestResultModel(
    sessionId: json['sessionId'],
    resultLevel: json['resultLevel'],
    score: json['score'],
    totalQuestions: json['totalQuestions'],
    review: (json['review'] as List).map((r) => ReviewItemModel.fromJson(r)).toList(),
  );
}
