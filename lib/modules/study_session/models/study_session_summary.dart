import 'package:englishme/modules/learn/models/curriculum_models.dart' show XpBonus;

/// Response từ `GET /api/study-sessions/{id}/summary`.
class StudySessionSummary {
  final int masteredCards;
  final int hardCards;
  final int againCards;
  final int xpEarned;
  final int newWordsLearned;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// XP của user sau khi grant (chỉ có khi phiên VỪA hoàn thành; null nếu chưa
  /// hoàn thành hoặc gọi lại summary). Dùng để apply XP 1 lần ở màn tổng kết.
  final int? totalXp;
  final bool streakUpdated;
  final List<XpBonus> bonuses;

  const StudySessionSummary({
    required this.masteredCards,
    required this.hardCards,
    required this.againCards,
    required this.xpEarned,
    required this.newWordsLearned,
    this.startedAt,
    this.completedAt,
    this.totalXp,
    this.streakUpdated = false,
    this.bonuses = const [],
  });

  factory StudySessionSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic raw) =>
        raw is String ? DateTime.tryParse(raw) : null;
    final rawBonuses = json['bonuses'];
    return StudySessionSummary(
      masteredCards: (json['masteredCards'] as num?)?.toInt() ?? 0,
      hardCards: (json['hardCards'] as num?)?.toInt() ?? 0,
      againCards: (json['againCards'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      newWordsLearned: (json['newWordsLearned'] as num?)?.toInt() ?? 0,
      startedAt: parse(json['startedAt']),
      completedAt: parse(json['completedAt']),
      totalXp: (json['totalXp'] as num?)?.toInt(),
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
