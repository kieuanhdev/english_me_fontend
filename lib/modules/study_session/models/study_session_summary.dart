/// Response từ `GET /api/study-sessions/{id}/summary`.
class StudySessionSummary {
  final int masteredCards;
  final int hardCards;
  final int againCards;
  final int xpEarned;
  final int newWordsLearned;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const StudySessionSummary({
    required this.masteredCards,
    required this.hardCards,
    required this.againCards,
    required this.xpEarned,
    required this.newWordsLearned,
    this.startedAt,
    this.completedAt,
  });

  factory StudySessionSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic raw) =>
        raw is String ? DateTime.tryParse(raw) : null;
    return StudySessionSummary(
      masteredCards: (json['masteredCards'] as num?)?.toInt() ?? 0,
      hardCards: (json['hardCards'] as num?)?.toInt() ?? 0,
      againCards: (json['againCards'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      newWordsLearned: (json['newWordsLearned'] as num?)?.toInt() ?? 0,
      startedAt: parse(json['startedAt']),
      completedAt: parse(json['completedAt']),
    );
  }
}
