enum ExerciseType { multipleChoice, fillBlank }

enum ExerciseDifficulty { easy, medium, hard }

enum ExerciseCategory { vocabulary, grammar }

class ExerciseQuestion {
  final String id;
  final ExerciseType type;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? hint;

  const ExerciseQuestion({
    required this.id,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.hint,
  });

  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) {
    return ExerciseQuestion(
      id: json['id'] as String,
      type: ExerciseType.values.firstWhere(
        (e) => e.name == (json['type'] as String),
        orElse: () => ExerciseType.multipleChoice,
      ),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String),
        orElse: () => ExerciseCategory.vocabulary,
      ),
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String),
        orElse: () => ExerciseDifficulty.medium,
      ),
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      hint: json['hint'] as String?,
    );
  }
}

class ExerciseSession {
  final String sessionId;
  final ExerciseCategory category;
  final List<ExerciseQuestion> questions;

  const ExerciseSession({
    required this.sessionId,
    required this.category,
    required this.questions,
  });

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      sessionId: json['sessionId'] as String,
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String),
        orElse: () => ExerciseCategory.vocabulary,
      ),
      questions: (json['questions'] as List)
          .map((q) => ExerciseQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExerciseAnswerResult {
  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String? explanation;

  const ExerciseAnswerResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
  });
}
