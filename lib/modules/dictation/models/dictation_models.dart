// Models cho luyện Nghe - chép chính tả (dictation).

import 'package:englishme/modules/learn/models/curriculum_models.dart' show BadgeAward;

class DictationSentence {
  final String id;
  final String level;
  final String text; // câu gốc = đáp án để chấm
  final String? hint;
  final String? audioUrl;

  const DictationSentence({
    required this.id,
    required this.level,
    required this.text,
    this.hint,
    this.audioUrl,
  });

  factory DictationSentence.fromJson(Map<String, dynamic> json) {
    return DictationSentence(
      id: (json['id'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      hint: json['hint'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

class DictationSession {
  final String sessionId;
  final String? level;
  final List<DictationSentence> sentences;

  const DictationSession({
    required this.sessionId,
    this.level,
    required this.sentences,
  });

  factory DictationSession.fromJson(Map<String, dynamic> json) {
    return DictationSession(
      sessionId: (json['sessionId'] ?? '').toString(),
      level: json['level'] as String?,
      sentences: (json['sentences'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DictationSentence.fromJson)
          .toList(),
    );
  }
}

class DictationCompleteResult {
  final int total;
  final int correct;
  final int incorrect;
  final double accuracyPercent;
  final int xpEarned;
  final int totalXp;
  final int dailyEarnedXp;
  final bool streakUpdated;
  final List<BadgeAward> newBadges;

  const DictationCompleteResult({
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.accuracyPercent,
    required this.xpEarned,
    required this.totalXp,
    required this.dailyEarnedXp,
    required this.streakUpdated,
    this.newBadges = const [],
  });

  factory DictationCompleteResult.fromJson(Map<String, dynamic> json) {
    return DictationCompleteResult(
      total: (json['total'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      incorrect: (json['incorrect'] as num?)?.toInt() ?? 0,
      accuracyPercent: (json['accuracyPercent'] as num?)?.toDouble() ?? 0.0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      dailyEarnedXp: (json['dailyEarnedXp'] as num?)?.toInt() ?? 0,
      streakUpdated: json['streakUpdated'] == true,
      newBadges: BadgeAward.listFrom(json['newBadges']),
    );
  }
}
