// Models cho luyện Viết theo đề với AI.

import 'package:englishme/modules/learn/models/curriculum_models.dart' show BadgeAward;

class WritingPrompt {
  final String promptId;
  final String level;
  final String title;
  final String prompt;
  final int minWords;

  const WritingPrompt({
    required this.promptId,
    required this.level,
    required this.title,
    required this.prompt,
    required this.minWords,
  });

  factory WritingPrompt.fromJson(Map<String, dynamic> json) {
    return WritingPrompt(
      promptId: (json['promptId'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      title: (json['title'] ?? 'Bài viết').toString(),
      prompt: (json['prompt'] ?? '').toString(),
      minWords: (json['minWords'] as num?)?.toInt() ?? 0,
    );
  }
}

class WritingGrade {
  final int score;
  final String correctedEssay;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> vocabSuggestions;
  final String encouragement;
  final int xpEarned;
  final int totalXp;
  final int dailyEarnedXp;
  final bool streakUpdated;
  final List<BadgeAward> newBadges;

  const WritingGrade({
    required this.score,
    required this.correctedEssay,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.vocabSuggestions,
    required this.encouragement,
    required this.xpEarned,
    required this.totalXp,
    required this.dailyEarnedXp,
    required this.streakUpdated,
    this.newBadges = const [],
  });

  factory WritingGrade.fromJson(Map<String, dynamic> json) {
    List<String> list(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
    return WritingGrade(
      score: (json['score'] as num?)?.round() ?? 0,
      correctedEssay: (json['correctedEssay'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      strengths: list(json['strengths']),
      improvements: list(json['improvements']),
      vocabSuggestions: list(json['vocabSuggestions']),
      encouragement: (json['encouragement'] ?? '').toString(),
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      dailyEarnedXp: (json['dailyEarnedXp'] as num?)?.toInt() ?? 0,
      streakUpdated: json['streakUpdated'] == true,
      newBadges: BadgeAward.listFrom(json['newBadges']),
    );
  }
}
