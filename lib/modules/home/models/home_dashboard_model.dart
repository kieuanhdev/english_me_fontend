/// Response từ `GET /api/home/dashboard` (mục 11.3 PROJECT_DOCUMENTATION).
class HomeDashboardResponse {
  final HomeUserSection user;
  final DailyStats dailyStats;
  final WordOfDayDto? wordOfDay;
  final ContinueLearning? continueLearning;
  final List<HomeRecommendation> recommendations;

  const HomeDashboardResponse({
    required this.user,
    required this.dailyStats,
    this.wordOfDay,
    this.continueLearning,
    required this.recommendations,
  });

  factory HomeDashboardResponse.fromJson(Map<String, dynamic> json) {
    final recs = json['recommendations'];
    return HomeDashboardResponse(
      user: HomeUserSection.fromJson(json['user'] as Map<String, dynamic>? ?? const {}),
      dailyStats: DailyStats.fromJson(json['dailyStats'] as Map<String, dynamic>? ?? const {}),
      wordOfDay: json['wordOfDay'] is Map<String, dynamic>
          ? WordOfDayDto.fromJson(json['wordOfDay'] as Map<String, dynamic>)
          : null,
      continueLearning: json['continueLearning'] is Map<String, dynamic>
          ? ContinueLearning.fromJson(json['continueLearning'] as Map<String, dynamic>)
          : null,
      recommendations: recs is List
          ? recs
                .whereType<Map<String, dynamic>>()
                .map(HomeRecommendation.fromJson)
                .toList()
          : const [],
    );
  }
}

class HomeUserSection {
  final String? fullName;
  final String? avatarUrl;
  final String? cefrLevel;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;

  const HomeUserSection({
    this.fullName,
    this.avatarUrl,
    this.cefrLevel,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory HomeUserSection.fromJson(Map<String, dynamic> json) => HomeUserSection(
    fullName: json['fullName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    cefrLevel: json['cefrLevel'] as String?,
    totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
    currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  );
}

class DailyStats {
  final int xpToday;
  final int xpWeek;
  final int activeDaysThisWeek;
  final int currentStreak;

  const DailyStats({
    required this.xpToday,
    required this.xpWeek,
    required this.activeDaysThisWeek,
    required this.currentStreak,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    xpToday: (json['xpToday'] as num?)?.toInt() ?? 0,
    xpWeek: (json['xpWeek'] as num?)?.toInt() ?? 0,
    activeDaysThisWeek: (json['activeDaysThisWeek'] as num?)?.toInt() ?? 0,
    currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  );
}

class WordOfDayDto {
  final String id;
  final String word;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? definitionVi;
  final String? definitionEn;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? level;

  const WordOfDayDto({
    required this.id,
    required this.word,
    this.pronunciation,
    this.partOfSpeech,
    this.definitionVi,
    this.definitionEn,
    this.exampleSentence,
    this.exampleTranslation,
    this.level,
  });

  factory WordOfDayDto.fromJson(Map<String, dynamic> json) => WordOfDayDto(
    id: (json['id'] ?? '').toString(),
    word: (json['word'] ?? '').toString(),
    pronunciation: json['pronunciation'] as String?,
    partOfSpeech: json['partOfSpeech'] as String?,
    definitionVi: json['definitionVi'] as String?,
    definitionEn: json['definitionEn'] as String?,
    exampleSentence: json['exampleSentence'] as String?,
    exampleTranslation: json['exampleTranslation'] as String?,
    level: json['level'] as String?,
  );
}

class ContinueLearning {
  final String? type;
  final String? topicId;
  final String? title;
  final String? level;
  final String? slug;

  const ContinueLearning({
    this.type,
    this.topicId,
    this.title,
    this.level,
    this.slug,
  });

  factory ContinueLearning.fromJson(Map<String, dynamic> json) => ContinueLearning(
    type: json['type'] as String?,
    topicId: json['topicId']?.toString(),
    title: json['title'] as String?,
    level: json['level'] as String?,
    slug: json['slug'] as String?,
  );
}

class HomeRecommendation {
  final String type;
  final String title;
  final String description;
  final String? actionUrl;

  const HomeRecommendation({
    required this.type,
    required this.title,
    required this.description,
    this.actionUrl,
  });

  factory HomeRecommendation.fromJson(Map<String, dynamic> json) => HomeRecommendation(
    type: (json['type'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    actionUrl: json['actionUrl'] as String?,
  );
}
