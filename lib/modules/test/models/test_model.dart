enum TestTopic { grammar, vocabulary }

enum TestLevel { a1, a2, b1, b2, c1, c2 }

enum TestState { idle, loading, playing, submitting, finished, error }

extension TestTopicExt on TestTopic {
  String get label => switch (this) {
    TestTopic.grammar => 'Ngữ pháp',
    TestTopic.vocabulary => 'Từ vựng',
  };

  static TestTopic fromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'grammar':
        return TestTopic.grammar;
      case 'vocabulary':
        return TestTopic.vocabulary;
      default:
        return TestTopic.grammar;
    }
  }
}

extension TestLevelExt on TestLevel {
  String get label => name.toUpperCase();

  static TestLevel fromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'a1':
        return TestLevel.a1;
      case 'a2':
        return TestLevel.a2;
      case 'b1':
        return TestLevel.b1;
      case 'b2':
        return TestLevel.b2;
      case 'c1':
        return TestLevel.c1;
      case 'c2':
        return TestLevel.c2;
      default:
        return TestLevel.a1;
    }
  }
}

class TestQuestion {
  final String id;
  final TestTopic topic;
  final TestLevel level;
  final String question;
  final List<String> options;
  final List<String> optionLabels;
  final String correctAnswer;
  final String? explanation;

  const TestQuestion({
    required this.id,
    required this.topic,
    required this.level,
    required this.question,
    required this.options,
    required this.optionLabels,
    required this.correctAnswer,
    this.explanation,
  });

  factory TestQuestion.fromJson(
    Map<String, dynamic> json, {
    required TestTopic topic,
    required TestLevel level,
  }) {
    final rawOptions = json['options'];
    final labels = <String>[];
    final texts = <String>[];

    if (rawOptions is Map<String, dynamic>) {
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

    return TestQuestion(
      id: (json['id'] ?? '').toString(),
      topic: topic,
      level: level,
      question: (json['question'] ?? '').toString(),
      options: texts,
      optionLabels: labels,
      correctAnswer: (json['correctAnswer'] ?? '').toString(),
      explanation: json['explanation'] as String?,
    );
  }

  String? labelFor(String optionText) {
    final idx = options.indexOf(optionText);
    if (idx < 0 || idx >= optionLabels.length) return null;
    return optionLabels[idx];
  }
}

class TestSession {
  final String sessionId;
  final TestTopic topic;
  final TestLevel level;
  final List<TestQuestion> questions;
  final int durationSeconds;

  const TestSession({
    required this.sessionId,
    required this.topic,
    required this.level,
    required this.questions,
    this.durationSeconds = 15 * 60,
  });

  factory TestSession.fromJson(Map<String, dynamic> json) {
    final topic = TestTopicExt.fromString(json['topic'] as String?);
    final level = TestLevelExt.fromString(json['level'] as String?);
    return TestSession(
      sessionId: (json['sessionId'] ?? '').toString(),
      topic: topic,
      level: level,
      questions: (json['questions'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((q) => TestQuestion.fromJson(q, topic: topic, level: level))
          .toList(),
      durationSeconds:
          (json['durationSeconds'] as num?)?.toInt() ?? (15 * 60),
    );
  }
}

class TestAnswerResult {
  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String? explanation;

  const TestAnswerResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
  });
}

class TestSubmitResponse {
  final String sessionId;
  final int totalQuestions;
  final int correct;
  final int incorrect;
  final double accuracyPercent;
  final int xpEarned;
  final String? cefrSuggestion;
  final int timeTakenSeconds;

  const TestSubmitResponse({
    required this.sessionId,
    required this.totalQuestions,
    required this.correct,
    required this.incorrect,
    required this.accuracyPercent,
    required this.xpEarned,
    this.cefrSuggestion,
    required this.timeTakenSeconds,
  });

  factory TestSubmitResponse.fromJson(Map<String, dynamic> json) {
    return TestSubmitResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      incorrect: (json['incorrect'] as num?)?.toInt() ?? 0,
      accuracyPercent: (json['accuracyPercent'] as num?)?.toDouble() ?? 0.0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      cefrSuggestion: json['cefrSuggestion'] as String?,
      timeTakenSeconds: (json['timeTakenSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}

class TestHistoryEntry {
  final String sessionId;
  final TestTopic topic;
  final TestLevel level;
  final int correct;
  final int total;
  final DateTime completedAt;

  const TestHistoryEntry({
    required this.sessionId,
    required this.topic,
    required this.level,
    required this.correct,
    required this.total,
    required this.completedAt,
  });

  factory TestHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TestHistoryEntry(
      sessionId: (json['sessionId'] ?? '').toString(),
      topic: TestTopicExt.fromString(json['topic'] as String?),
      level: TestLevelExt.fromString(json['level'] as String?),
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      total: (json['totalQuestions'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  double get accuracy => total > 0 ? correct / total : 0;
}
