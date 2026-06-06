class PronunciationExercise {
  const PronunciationExercise({
    required this.id,
    required this.text,
    this.phonetic,
    this.meaning,
    this.audioUrl,
    this.difficulty,
    this.level,
    this.tips,
  });

  final String id;
  final String text;
  final String? phonetic;
  final String? meaning;
  final String? audioUrl;
  final String? difficulty;
  final String? level;
  final String? tips;

  factory PronunciationExercise.fromJson(Map<String, dynamic> json) {
    return PronunciationExercise(
      id: json['id'] as String,
      text: json['text'] as String,
      phonetic: json['phonetic'] as String?,
      meaning: json['meaning'] as String?,
      audioUrl: json['audioUrl'] as String?,
      difficulty: json['difficulty'] as String?,
      level: json['level'] as String?,
      tips: json['tips'] as String?,
    );
  }
}

class PronunciationError {
  const PronunciationError({
    required this.word,
    required this.position,
    required this.expected,
    required this.actual,
    required this.suggestion,
  });

  final String word;
  final int position;
  final String expected;
  final String actual;
  final String suggestion;

  factory PronunciationError.fromJson(Map<String, dynamic> json) {
    return PronunciationError(
      word: json['word'] as String,
      position: json['position'] as int,
      expected: json['expected'] as String,
      actual: json['actual'] as String,
      suggestion: json['suggestion'] as String,
    );
  }
}

class PronunciationFeedback {
  const PronunciationFeedback({
    required this.score,
    required this.accuracy,
    required this.fluency,
    required this.completeness,
    required this.transcription,
    required this.errors,
    this.overallComment,
  });

  final double score;
  final double accuracy;
  final double fluency;
  final double completeness;
  final String transcription;
  final List<PronunciationError> errors;
  final String? overallComment;

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedback(
      score: (json['score'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      fluency: (json['fluency'] as num).toDouble(),
      completeness: (json['completeness'] as num).toDouble(),
      transcription: json['transcription'] as String,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) =>
                  PronunciationError.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overallComment: json['overallComment'] as String?,
    );
  }
}

/// Insight cá nhân hóa phát âm — `GET /api/pronunciation/insights`.
/// Tổng hợp lịch sử assess của user thành điểm TB, từ yếu nhất, phân bố lỗi.
class PronunciationInsight {
  const PronunciationInsight({
    required this.totalAttempts,
    required this.averageScore,
    required this.weakestWords,
    required this.issueBreakdown,
  });

  final int totalAttempts;
  final int averageScore;
  final List<WeakWord> weakestWords;
  final IssueBreakdown issueBreakdown;

  factory PronunciationInsight.fromJson(Map<String, dynamic> json) {
    final words = json['weakestWords'];
    return PronunciationInsight(
      totalAttempts: (json['totalAttempts'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toInt() ?? 0,
      weakestWords: words is List
          ? words
              .whereType<Map<String, dynamic>>()
              .map(WeakWord.fromJson)
              .toList()
          : const [],
      issueBreakdown: json['issueBreakdown'] is Map<String, dynamic>
          ? IssueBreakdown.fromJson(json['issueBreakdown'] as Map<String, dynamic>)
          : const IssueBreakdown(good: 0, minor: 0, critical: 0),
    );
  }
}

class WeakWord {
  const WeakWord({
    required this.word,
    required this.avgScore,
    required this.attempts,
    required this.lastIssueType,
    this.suggestion,
  });

  final String word;
  final int avgScore;
  final int attempts;

  /// "good" | "minor" | "critical".
  final String lastIssueType;
  final String? suggestion;

  factory WeakWord.fromJson(Map<String, dynamic> json) => WeakWord(
        word: (json['word'] ?? '').toString(),
        avgScore: (json['avgScore'] as num?)?.toInt() ?? 0,
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
        lastIssueType: (json['lastIssueType'] ?? 'good').toString(),
        suggestion: json['suggestion'] as String?,
      );
}

class IssueBreakdown {
  const IssueBreakdown({
    required this.good,
    required this.minor,
    required this.critical,
  });

  final int good;
  final int minor;
  final int critical;

  factory IssueBreakdown.fromJson(Map<String, dynamic> json) => IssueBreakdown(
        good: (json['good'] as num?)?.toInt() ?? 0,
        minor: (json['minor'] as num?)?.toInt() ?? 0,
        critical: (json['critical'] as num?)?.toInt() ?? 0,
      );
}
