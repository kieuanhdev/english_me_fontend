/// Response từ `GET /api/users/me/progress` (mục 11.4 PROJECT_DOCUMENTATION).
class ProgressResponse {
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final String? cefrLevel;
  final List<SkillScore> skills;
  final WeekSummary weekSummary;

  const ProgressResponse({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    this.cefrLevel,
    required this.skills,
    required this.weekSummary,
  });

  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    final skillsRaw = json['skills'];
    return ProgressResponse(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      cefrLevel: json['cefrLevel'] as String?,
      skills: skillsRaw is List
          ? skillsRaw
                .whereType<Map<String, dynamic>>()
                .map(SkillScore.fromJson)
                .toList()
          : const [],
      weekSummary: WeekSummary.fromJson(
        json['weekSummary'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class SkillScore {
  final String skill;
  final int score;
  final int? maxScore;

  const SkillScore({
    required this.skill,
    required this.score,
    this.maxScore,
  });

  factory SkillScore.fromJson(Map<String, dynamic> json) => SkillScore(
    skill: (json['skill'] ?? '').toString(),
    score: (json['score'] as num?)?.toInt() ?? 0,
    maxScore: (json['maxScore'] as num?)?.toInt(),
  );

  /// Normalize về 0..1 cho radar chart.
  double get normalized {
    final cap = maxScore ?? 100;
    if (cap <= 0) return 0;
    return (score / cap).clamp(0.0, 1.0);
  }
}

class WeekSummary {
  final int totalXp;
  final int activeDays;
  final int lessonsCompleted;

  const WeekSummary({
    required this.totalXp,
    required this.activeDays,
    required this.lessonsCompleted,
  });

  factory WeekSummary.fromJson(Map<String, dynamic> json) => WeekSummary(
    totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
    activeDays: (json['activeDays'] as num?)?.toInt() ?? 0,
    lessonsCompleted: (json['lessonsCompleted'] as num?)?.toInt() ?? 0,
  );
}
