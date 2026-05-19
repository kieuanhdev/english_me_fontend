class WeeklyXpEntry {
  final DateTime date;
  final int xp;

  const WeeklyXpEntry({required this.date, required this.xp});
}

class SkillBreakdown {
  final double vocabulary;
  final double grammar;
  final double pronunciation;
  final double listening;

  const SkillBreakdown({
    required this.vocabulary,
    required this.grammar,
    required this.pronunciation,
    required this.listening,
  });
}

/// Weekly summary đã đổi shape theo backend (mục 11.4):
/// `totalXp`, `activeDays`, `lessonsCompleted`. 3 metric cũ
/// (minutesStudied / accuracyRate / flashcardsReviewed) backend chưa hỗ trợ.
class WeeklySummary {
  final int totalXp;
  final int activeDays;
  final int lessonsCompleted;

  const WeeklySummary({
    required this.totalXp,
    required this.activeDays,
    required this.lessonsCompleted,
  });
}

class ProgressData {
  final String cefrLevel;
  final String cefrLabel;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int todayXp;
  final int xpGoal;

  final List<DateTime> studyDates;
  final List<WeeklyXpEntry> xpHistory;

  final SkillBreakdown skillBreakdown;
  final WeeklySummary weeklySummary;

  const ProgressData({
    required this.cefrLevel,
    required this.cefrLabel,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXp,
    required this.todayXp,
    required this.xpGoal,
    required this.studyDates,
    required this.xpHistory,
    required this.skillBreakdown,
    required this.weeklySummary,
  });
}
