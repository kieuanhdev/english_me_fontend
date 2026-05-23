class LearningHub {
  const LearningHub({
    required this.currentLevel,
    required this.selectedLevel,
    required this.levels,
    required this.skillTracks,
    required this.units,
    required this.supportTracks,
    required this.paths,
    this.nextRecommendedSkill,
    this.dailyGoal,
    this.currentPathId,
  });

  final String currentLevel;
  final String selectedLevel;
  final String? nextRecommendedSkill;
  final String? currentPathId;
  final LearningDailyGoal? dailyGoal;
  final List<LearningLevel> levels;
  final List<LearningSkillTrack> skillTracks;
  final List<LearningUnit> units;
  final List<LearningPath> paths;
  final List<LearningSupportTrack> supportTracks;

  factory LearningHub.fromJson(Map<String, dynamic> json) {
    final units = _listOf(json['units'], LearningUnit.fromJson);
    final rawPaths = _listOf(json['paths'], LearningPath.fromJson);
    return LearningHub(
      currentLevel: (json['currentLevel'] ?? 'A1').toString(),
      selectedLevel: (json['selectedLevel'] ?? json['currentLevel'] ?? 'A1')
          .toString(),
      nextRecommendedSkill: json['nextRecommendedSkill']?.toString(),
      currentPathId: json['currentPathId']?.toString(),
      dailyGoal: json['dailyGoal'] is Map<String, dynamic>
          ? LearningDailyGoal.fromJson(
              json['dailyGoal'] as Map<String, dynamic>,
            )
          : null,
      levels: _listOf(json['levels'], LearningLevel.fromJson),
      skillTracks: _listOf(json['skillTracks'], LearningSkillTrack.fromJson),
      units: units,
      paths: rawPaths.isNotEmpty
          ? rawPaths
          : units.map(LearningPath.fromUnit).toList(growable: false),
      supportTracks: _listOf(
        json['supportTracks'],
        LearningSupportTrack.fromJson,
      ),
    );
  }
}

class LearningPath {
  const LearningPath({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    required this.order,
    required this.status,
    required this.progress,
    required this.activityCount,
    required this.completedActivityCount,
    required this.skillsCoverage,
  });

  final String id;
  final String level;
  final String title;
  final String description;
  final int order;
  final String status;
  final double progress;
  final int activityCount;
  final int completedActivityCount;
  final List<String> skillsCoverage;

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    final activityCount = _asInt(json['activityCount'] ?? json['lessonCount']);
    final completedActivityCount = _asInt(
      json['completedActivityCount'] ?? json['completedLessonCount'],
    );
    final explicitProgress = _asDouble(json['progress']);
    final computedProgress = activityCount <= 0
        ? 0.0
        : completedActivityCount / activityCount;
    return LearningPath(
      id: (json['id'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? json['subtitle'] ?? '').toString(),
      order: _asInt(json['order']),
      status: (json['status'] ?? 'available').toString(),
      progress: (explicitProgress > 0 ? explicitProgress : computedProgress)
          .clamp(0, 1)
          .toDouble(),
      activityCount: activityCount,
      completedActivityCount: completedActivityCount,
      skillsCoverage:
          ((json['skillsCoverage'] ?? json['skillCoverage'])
                      as List<dynamic>? ??
                  const [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  factory LearningPath.fromUnit(LearningUnit unit) {
    final progress = unit.lessonCount <= 0
        ? 0.0
        : unit.completedLessonCount / unit.lessonCount;
    return LearningPath(
      id: unit.id,
      level: unit.level,
      title: unit.title,
      description: unit.subtitle,
      order: 0,
      status: unit.status,
      progress: progress.clamp(0, 1).toDouble(),
      activityCount: unit.lessonCount,
      completedActivityCount: unit.completedLessonCount,
      skillsCoverage: unit.skillCoverage,
    );
  }
}

class LearningPathDetail {
  const LearningPathDetail({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.requiredScoreToPass,
    required this.activities,
  });

  final String id;
  final String level;
  final String title;
  final String description;
  final String status;
  final double progress;
  final int requiredScoreToPass;
  final List<LearningPathActivity> activities;

  factory LearningPathDetail.fromJson(Map<String, dynamic> json) {
    return LearningPathDetail(
      id: (json['id'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'available').toString(),
      progress: _asDouble(json['progress']).clamp(0, 1).toDouble(),
      requiredScoreToPass: _asInt(json['requiredScoreToPass']),
      activities: _listOf(json['activities'], LearningPathActivity.fromJson),
    );
  }
}

class LearningPathActivity {
  const LearningPathActivity({
    required this.id,
    required this.pathId,
    required this.title,
    required this.subtitle,
    required this.skill,
    required this.type,
    required this.status,
    required this.order,
    required this.durationMinutes,
    required this.xpReward,
  });

  final String id;
  final String pathId;
  final String title;
  final String subtitle;
  final String skill;
  final String type;
  final String status;
  final int order;
  final int durationMinutes;
  final int xpReward;

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';

  factory LearningPathActivity.fromJson(Map<String, dynamic> json) {
    return LearningPathActivity(
      id: (json['id'] ?? '').toString(),
      pathId: (json['pathId'] ?? json['unitId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      skill: (json['skill'] ?? '').toString(),
      type: (json['type'] ?? json['activityType'] ?? 'lesson').toString(),
      status: (json['status'] ?? 'available').toString(),
      order: _asInt(json['order']),
      durationMinutes: _asInt(json['durationMinutes']),
      xpReward: _asInt(json['xpReward']),
    );
  }

  factory LearningPathActivity.fromLesson({
    required LearningLessonListItem lesson,
    required String skill,
  }) {
    return LearningPathActivity(
      id: lesson.id,
      pathId: lesson.unitId,
      title: lesson.title,
      subtitle: lesson.subtitle,
      skill: skill,
      type: lesson.activityType,
      status: lesson.status,
      order: lesson.order,
      durationMinutes: lesson.durationMinutes,
      xpReward: lesson.xpReward,
    );
  }
}

class LearningDailyGoal {
  const LearningDailyGoal({
    required this.targetXp,
    required this.earnedXp,
    required this.completedActivities,
  });

  final int targetXp;
  final int earnedXp;
  final int completedActivities;

  double get progress =>
      targetXp <= 0 ? 0 : (earnedXp / targetXp).clamp(0, 1).toDouble();

  factory LearningDailyGoal.fromJson(Map<String, dynamic> json) {
    return LearningDailyGoal(
      targetXp: _asInt(json['targetXp']),
      earnedXp: _asInt(json['earnedXp']),
      completedActivities: _asInt(json['completedActivities']),
    );
  }
}

class LearningLevel {
  const LearningLevel({
    required this.code,
    required this.title,
    required this.description,
    required this.progress,
    required this.status,
    required this.locked,
  });

  final String code;
  final String title;
  final String description;
  final double progress;
  final String status;
  final bool locked;

  factory LearningLevel.fromJson(Map<String, dynamic> json) {
    return LearningLevel(
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      progress: _asDouble(json['progress']).clamp(0, 1).toDouble(),
      status: (json['status'] ?? 'available').toString(),
      locked: json['locked'] == true,
    );
  }
}

class LearningSkillTrack {
  const LearningSkillTrack({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
    required this.enabled,
    this.nextLessonId,
  });

  final String type;
  final String title;
  final String description;
  final String icon;
  final String accentColor;
  final double progress;
  final int totalLessons;
  final int completedLessons;
  final String? nextLessonId;
  final bool enabled;

  factory LearningSkillTrack.fromJson(Map<String, dynamic> json) {
    return LearningSkillTrack(
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      accentColor: (json['accentColor'] ?? '').toString(),
      progress: _asDouble(json['progress']).clamp(0, 1).toDouble(),
      totalLessons: _asInt(json['totalLessons']),
      completedLessons: _asInt(json['completedLessons']),
      nextLessonId: json['nextLessonId']?.toString(),
      enabled: json['enabled'] != false,
    );
  }
}

class LearningUnit {
  const LearningUnit({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.lessonCount,
    required this.completedLessonCount,
    required this.status,
    required this.skillCoverage,
  });

  final String id;
  final String level;
  final String title;
  final String subtitle;
  final int lessonCount;
  final int completedLessonCount;
  final String status;
  final List<String> skillCoverage;

  factory LearningUnit.fromJson(Map<String, dynamic> json) {
    return LearningUnit(
      id: (json['id'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      lessonCount: _asInt(json['lessonCount']),
      completedLessonCount: _asInt(json['completedLessonCount']),
      status: (json['status'] ?? 'available').toString(),
      skillCoverage: (json['skillCoverage'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class LearningSupportTrack {
  const LearningSupportTrack({
    required this.type,
    required this.title,
    required this.description,
    required this.route,
    required this.progress,
    required this.enabled,
  });

  final String type;
  final String title;
  final String description;
  final String route;
  final double progress;
  final bool enabled;

  factory LearningSupportTrack.fromJson(Map<String, dynamic> json) {
    return LearningSupportTrack(
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      route: (json['route'] ?? '').toString(),
      progress: _asDouble(json['progress']).clamp(0, 1).toDouble(),
      enabled: json['enabled'] != false,
    );
  }
}

class LearningSkillLessons {
  const LearningSkillLessons({
    required this.level,
    required this.skill,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String level;
  final String skill;
  final String title;
  final String description;
  final List<LearningLessonListItem> lessons;

  factory LearningSkillLessons.fromJson(Map<String, dynamic> json) {
    return LearningSkillLessons(
      level: (json['level'] ?? '').toString(),
      skill: (json['skill'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      lessons: _listOf(json['lessons'], LearningLessonListItem.fromJson),
    );
  }
}

class LearningLessonListItem {
  const LearningLessonListItem({
    required this.id,
    required this.unitId,
    required this.title,
    required this.subtitle,
    required this.activityType,
    required this.durationMinutes,
    required this.xpReward,
    required this.status,
    required this.order,
  });

  final String id;
  final String unitId;
  final String title;
  final String subtitle;
  final String activityType;
  final int durationMinutes;
  final int xpReward;
  final String status;
  final int order;

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';

  factory LearningLessonListItem.fromJson(Map<String, dynamic> json) {
    return LearningLessonListItem(
      id: (json['id'] ?? '').toString(),
      unitId: (json['unitId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      activityType: (json['activityType'] ?? 'lesson').toString(),
      durationMinutes: _asInt(json['durationMinutes']),
      xpReward: _asInt(json['xpReward']),
      status: (json['status'] ?? 'available').toString(),
      order: _asInt(json['order']),
    );
  }
}

class LearningLessonDetail {
  const LearningLessonDetail({
    required this.id,
    required this.level,
    required this.skill,
    required this.unitId,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.xpReward,
    required this.status,
    required this.content,
    required this.activities,
  });

  final String id;
  final String level;
  final String skill;
  final String unitId;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final int xpReward;
  final String status;
  final Map<String, dynamic> content;
  final List<LearningActivity> activities;

  factory LearningLessonDetail.fromJson(Map<String, dynamic> json) {
    return LearningLessonDetail(
      id: (json['id'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      skill: (json['skill'] ?? '').toString(),
      unitId: (json['unitId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      durationMinutes: _asInt(json['durationMinutes']),
      xpReward: _asInt(json['xpReward']),
      status: (json['status'] ?? 'available').toString(),
      content: json['content'] is Map<String, dynamic>
          ? json['content'] as Map<String, dynamic>
          : const {},
      activities: _listOf(json['activities'], LearningActivity.fromJson),
    );
  }
}

class LearningActivity {
  const LearningActivity({
    required this.id,
    required this.type,
    required this.raw,
  });

  final String id;
  final String type;
  final Map<String, dynamic> raw;

  String get question => (raw['question'] ?? '').toString();
  String get prompt => (raw['prompt'] ?? '').toString();
  String get expectedText => (raw['expectedText'] ?? '').toString();
  String get explanationVi => (raw['explanationVi'] ?? '').toString();
  String? get correctOptionId => raw['correctOptionId']?.toString();
  int get minScoreToPass => _asInt(raw['minScoreToPass']);

  List<LearningOption> get options =>
      _listOf(raw['options'], LearningOption.fromJson);

  List<String> get rubric => (raw['rubric'] as List<dynamic>? ?? const [])
      .map((e) => e.toString())
      .toList();

  factory LearningActivity.fromJson(Map<String, dynamic> json) {
    return LearningActivity(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      raw: json,
    );
  }
}

class LearningOption {
  const LearningOption({required this.id, required this.text});

  final String id;
  final String text;

  factory LearningOption.fromJson(Map<String, dynamic> json) {
    return LearningOption(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
    );
  }
}

class LearningCompleteResponse {
  const LearningCompleteResponse({
    required this.lessonId,
    required this.completed,
    required this.score,
    required this.xpEarned,
    required this.levelProgress,
    required this.skillProgress,
    required this.streakUpdated,
    this.nextLessonId,
  });

  final String lessonId;
  final bool completed;
  final int score;
  final int xpEarned;
  final double levelProgress;
  final double skillProgress;
  final String? nextLessonId;
  final bool streakUpdated;

  factory LearningCompleteResponse.fromJson(Map<String, dynamic> json) {
    return LearningCompleteResponse(
      lessonId: (json['lessonId'] ?? '').toString(),
      completed: json['completed'] == true,
      score: _asInt(json['score']),
      xpEarned: _asInt(json['xpEarned']),
      levelProgress: _asDouble(json['levelProgress']).clamp(0, 1).toDouble(),
      skillProgress: _asDouble(json['skillProgress']).clamp(0, 1).toDouble(),
      nextLessonId: json['nextLessonId']?.toString(),
      streakUpdated: json['streakUpdated'] == true,
    );
  }
}

List<T> _listOf<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
