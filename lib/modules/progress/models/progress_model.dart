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

class WeeklySummary {
  final int minutesStudied;
  final int exercisesCompleted;
  final double accuracyRate;
  final int flashcardsReviewed;

  const WeeklySummary({
    required this.minutesStudied,
    required this.exercisesCompleted,
    required this.accuracyRate,
    required this.flashcardsReviewed,
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

  /// Dates that the user studied (for streak calendar)
  final List<DateTime> studyDates;

  /// XP per day for last 14 days
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

  factory ProgressData.mock() {
    final now = DateTime.now();
    return ProgressData(
      cefrLevel: 'A2',
      cefrLabel: 'PRE-INTERMEDIATE',
      currentStreak: 7,
      longestStreak: 14,
      totalXp: 2340,
      todayXp: 35,
      xpGoal: 50,
      studyDates: List.generate(
        25,
        (i) {
          final d = now.subtract(Duration(days: i));
          // Simulate some missed days
          if (i == 3 || i == 8 || i == 15) return null;
          return DateTime(d.year, d.month, d.day);
        },
      ).whereType<DateTime>().toList(),
      xpHistory: List.generate(14, (i) {
        final d = now.subtract(Duration(days: 13 - i));
        final xpValues = [20, 45, 30, 80, 55, 40, 15, 60, 75, 90, 35, 50, 70, 35];
        return WeeklyXpEntry(date: d, xp: xpValues[i]);
      }),
      skillBreakdown: const SkillBreakdown(
        vocabulary: 0.72,
        grammar: 0.58,
        pronunciation: 0.65,
        listening: 0.44,
      ),
      weeklySummary: const WeeklySummary(
        minutesStudied: 186,
        exercisesCompleted: 12,
        accuracyRate: 0.74,
        flashcardsReviewed: 48,
      ),
    );
  }
}
