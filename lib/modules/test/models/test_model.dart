enum TestTopic { grammar, vocabulary, pronunciation }

enum TestLevel { a1, a2, b1, b2, c1, c2 }

enum TestState { idle, loading, playing, finished, error }

extension TestTopicExt on TestTopic {
  String get label => switch (this) {
        TestTopic.grammar => 'Ngữ pháp',
        TestTopic.vocabulary => 'Từ vựng',
        TestTopic.pronunciation => 'Phát âm',
      };
}

extension TestLevelExt on TestLevel {
  String get label => name.toUpperCase();
}

class TestQuestion {
  final String id;
  final TestTopic topic;
  final TestLevel level;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  const TestQuestion({
    required this.id,
    required this.topic,
    required this.level,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });
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

  double get accuracy => total > 0 ? correct / total : 0;
}
