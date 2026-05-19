enum ExerciseType { multipleChoice, fillBlank }

enum ExerciseDifficulty { easy, medium, hard }

enum ExerciseCategory { vocabulary, grammar }

/// Câu hỏi exercise / user test.
/// Backend trả `options` dạng `{A: ..., B: ..., C: ..., D: ...}`.
/// Mobile flatten thành `List<String>` để render, đồng thời lưu `optionLabels`
/// để gửi lại `selectedAnswer` dạng key A/B/C/D khi submit.
class ExerciseQuestion {
  final String id;
  final ExerciseType type;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final String question;
  final List<String> options;
  final List<String> optionLabels;
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
    required this.optionLabels,
    required this.correctAnswer,
    this.explanation,
    this.hint,
  });

  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final labels = <String>[];
    final texts = <String>[];

    if (rawOptions is Map<String, dynamic>) {
      // Backend shape: { "A": "...", "B": "...", "C": "...", "D": "..." }
      final keys = rawOptions.keys.toList()..sort();
      for (final k in keys) {
        labels.add(k);
        texts.add((rawOptions[k] ?? '').toString());
      }
    } else if (rawOptions is List) {
      for (var i = 0; i < rawOptions.length; i++) {
        labels.add(String.fromCharCode(65 + i));
        texts.add(rawOptions[i].toString());
      }
    }

    return ExerciseQuestion(
      id: (json['id'] ?? '').toString(),
      type: ExerciseType.values.firstWhere(
        (e) => e.name == (json['type'] as String?),
        orElse: () => ExerciseType.multipleChoice,
      ),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => ExerciseCategory.vocabulary,
      ),
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String?),
        orElse: () => ExerciseDifficulty.medium,
      ),
      question: (json['question'] ?? '').toString(),
      options: texts,
      optionLabels: labels,
      correctAnswer: (json['correctAnswer'] ?? '').toString(),
      explanation: json['explanation'] as String?,
      hint: json['hint'] as String?,
    );
  }

  /// Map text option → label (A/B/C/D). Trả về null nếu không tìm thấy.
  String? labelFor(String optionText) {
    final idx = options.indexOf(optionText);
    if (idx < 0 || idx >= optionLabels.length) return null;
    return optionLabels[idx];
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
      sessionId: (json['sessionId'] ?? '').toString(),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => ExerciseCategory.vocabulary,
      ),
      questions: (json['questions'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExerciseQuestion.fromJson)
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

class ExerciseCompleteResponse {
  final int totalQuestions;
  final int correct;
  final int incorrect;
  final double accuracyPercent;
  final int xpEarned;

  const ExerciseCompleteResponse({
    required this.totalQuestions,
    required this.correct,
    required this.incorrect,
    required this.accuracyPercent,
    required this.xpEarned,
  });

  factory ExerciseCompleteResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseCompleteResponse(
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      incorrect: (json['incorrect'] as num?)?.toInt() ?? 0,
      accuracyPercent: (json['accuracyPercent'] as num?)?.toDouble() ?? 0.0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }
}
