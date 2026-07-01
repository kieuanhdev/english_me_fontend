import 'package:englishme/modules/learn/models/curriculum_models.dart' show XpBonus, BadgeAward;

enum ExerciseType { multipleChoice, fillBlank }

enum ExerciseDifficulty { easy, medium, hard }

enum ExerciseCategory { vocabulary, grammar, reading }

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
  final String? passage;
  final String? audioUrl;

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
    this.passage,
    this.audioUrl,
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
      passage: json['passage'] as String?,
      audioUrl: json['audioUrl'] as String?,
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
  final int totalXp;
  final int dailyEarnedXp;
  final bool streakUpdated;
  final List<XpBonus> bonuses;
  final List<BadgeAward> newBadges;

  const ExerciseCompleteResponse({
    required this.totalQuestions,
    required this.correct,
    required this.incorrect,
    required this.accuracyPercent,
    required this.xpEarned,
    required this.totalXp,
    required this.dailyEarnedXp,
    required this.streakUpdated,
    this.bonuses = const [],
    this.newBadges = const [],
  });

  factory ExerciseCompleteResponse.fromJson(Map<String, dynamic> json) {
    final rawBonuses = json['bonuses'];
    return ExerciseCompleteResponse(
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      incorrect: (json['incorrect'] as num?)?.toInt() ?? 0,
      accuracyPercent: (json['accuracyPercent'] as num?)?.toDouble() ?? 0.0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      dailyEarnedXp: (json['dailyEarnedXp'] as num?)?.toInt() ?? 0,
      streakUpdated: json['streakUpdated'] == true,
      bonuses: rawBonuses is List
          ? rawBonuses
              .whereType<Map<String, dynamic>>()
              .map(XpBonus.fromJson)
              .toList()
          : const [],
      newBadges: BadgeAward.listFrom(json['newBadges']),
    );
  }
}
