/// Body cho `POST /api/study-sessions/{id}/review`.
class ReviewRequest {
  final String flashcardId;
  final int quality;
  final int responseTimeMs;

  const ReviewRequest({
    required this.flashcardId,
    required this.quality,
    required this.responseTimeMs,
  });

  Map<String, dynamic> toJson() => {
    'flashcardId': flashcardId,
    'quality': quality,
    'responseTimeMs': responseTimeMs,
  };
}

/// Response sau khi review 1 thẻ.
class ReviewResponse {
  final int repetitions;
  final double easinessFactor;
  final int intervalDays;
  final DateTime? nextReviewAt;
  final int xpEarned;
  final int sessionXp;
  final int reviewedCount;
  final int totalCards;

  const ReviewResponse({
    required this.repetitions,
    required this.easinessFactor,
    required this.intervalDays,
    this.nextReviewAt,
    required this.xpEarned,
    required this.sessionXp,
    required this.reviewedCount,
    required this.totalCards,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    final next = json['nextReviewAt'];
    return ReviewResponse(
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      nextReviewAt: next is String ? DateTime.tryParse(next) : null,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      sessionXp: (json['sessionXp'] as num?)?.toInt() ?? 0,
      reviewedCount: (json['reviewedCount'] as num?)?.toInt() ?? 0,
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
    );
  }
}
