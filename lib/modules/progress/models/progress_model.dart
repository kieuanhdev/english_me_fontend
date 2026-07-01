class WeeklyXpEntry {
  final DateTime date;
  final int xp;

  const WeeklyXpEntry({required this.date, required this.xp});
}

class SkillBreakdown {
  final double vocabulary;
  final double grammar;
  final double reading;
  final double listening;
  final double speaking;
  final double writing;
  final double pronunciation;

  const SkillBreakdown({
    required this.vocabulary,
    required this.grammar,
    required this.reading,
    required this.listening,
    required this.speaking,
    required this.writing,
    required this.pronunciation,
  });

  /// Tất cả kỹ năng kèm value (0..1). value < 0 = không có dữ liệu (skill không
  /// gắn lesson) → caller lọc ra trước khi hiển thị / so sánh.
  Map<String, double> get all => {
    'vocabulary': vocabulary,
    'grammar': grammar,
    'reading': reading,
    'listening': listening,
    'speaking': speaking,
    'writing': writing,
    'pronunciation': pronunciation,
  };

  /// Chỉ các kỹ năng CÓ dữ liệu (value >= 0) — dùng để vẽ bar và tìm kỹ năng yếu.
  Map<String, double> get withData =>
      Map.fromEntries(all.entries.where((e) => e.value >= 0));
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
