class PronunciationExercise {
  const PronunciationExercise({
    required this.id,
    required this.text,
    this.phonetic,
    this.meaning,
    this.audioUrl,
    this.difficulty,
  });

  final String id;
  final String text;
  final String? phonetic;
  final String? meaning;
  final String? audioUrl;
  final String? difficulty;

  factory PronunciationExercise.fromJson(Map<String, dynamic> json) {
    return PronunciationExercise(
      id: json['id'] as String,
      text: json['text'] as String,
      phonetic: json['phonetic'] as String?,
      meaning: json['meaning'] as String?,
      audioUrl: json['audioUrl'] as String?,
      difficulty: json['difficulty'] as String?,
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
