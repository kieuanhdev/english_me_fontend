import 'package:englishme/modules/learn/models/learning_models.dart' show XpBonus;

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
  final int totalXp;
  final int dailyEarnedXp;
  final bool streakUpdated;
  final List<XpBonus> bonuses;

  const ReviewResponse({
    required this.repetitions,
    required this.easinessFactor,
    required this.intervalDays,
    this.nextReviewAt,
    required this.xpEarned,
    required this.sessionXp,
    required this.reviewedCount,
    required this.totalCards,
    required this.totalXp,
    required this.dailyEarnedXp,
    required this.streakUpdated,
    this.bonuses = const [],
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    final next = json['nextReviewAt'];
    final rawBonuses = json['bonuses'];
    return ReviewResponse(
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      nextReviewAt: next is String ? DateTime.tryParse(next) : null,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      sessionXp: (json['sessionXp'] as num?)?.toInt() ?? 0,
      reviewedCount: (json['reviewedCount'] as num?)?.toInt() ?? 0,
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      dailyEarnedXp: (json['dailyEarnedXp'] as num?)?.toInt() ?? 0,
      streakUpdated: json['streakUpdated'] == true,
      bonuses: rawBonuses is List
          ? rawBonuses
              .whereType<Map<String, dynamic>>()
              .map(XpBonus.fromJson)
              .toList()
          : const [],
    );
  }
}
