import 'package:dio/dio.dart';

import 'package:englishme/modules/learn/models/learning_models.dart';

class LearningRepository {
  LearningRepository(this._dio);

  final Dio _dio;

  Future<LearningHub> getHub({String? level}) async {
    final response = await _dio.get(
      '/learning/hub',
      queryParameters: level == null ? null : {'level': level},
    );
    return _withDemoPaths(LearningHub.fromJson(_asMap(response.data)));
  }

  Future<LearningSkillLessons> getSkillLessons({
    required String level,
    required String skill,
  }) async {
    final response = await _dio.get(
      '/learning/levels/$level/skills/$skill/lessons',
    );
    return LearningSkillLessons.fromJson(_asMap(response.data));
  }

  Future<LearningPathDetail> getPathDetail({
    required String level,
    required String pathId,
  }) async {
    if (_isDemoPathId(pathId)) return _demoPathDetail(level, pathId);
    try {
      final response = await _dio.get('/learning/paths/$pathId');
      return LearningPathDetail.fromJson(_asMap(response.data));
    } catch (_) {
      final detail = await _buildPathDetailFromSkillLessons(
        level: level,
        pathId: pathId,
      );
      return detail.activities.isEmpty
          ? _demoPathDetail(level, pathId)
          : detail;
    }
  }

  Future<LearningLessonDetail> getLessonDetail(String lessonId) async {
    try {
      final response = await _dio.get('/learning/lessons/$lessonId');
      return LearningLessonDetail.fromJson(_asMap(response.data));
    } catch (_) {
      if (_isDemoActivityId(lessonId)) return _demoLessonDetail(lessonId);
      rethrow;
    }
  }

  Future<LearningCompleteResponse> completeLesson({
    required String lessonId,
    required int score,
    required int timeSpentSeconds,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _dio.post(
        '/learning/lessons/$lessonId/complete',
        data: {
          'score': score,
          'timeSpentSeconds': timeSpentSeconds,
          'answers': answers,
        },
      );
      return LearningCompleteResponse.fromJson(_asMap(response.data));
    } catch (_) {
      if (_isDemoActivityId(lessonId)) {
        final nextLessonId = _nextDemoActivityId(lessonId);
        return LearningCompleteResponse(
          lessonId: lessonId,
          completed: true,
          score: score,
          xpEarned: 10,
          levelProgress: 0.42,
          skillProgress: 0.35,
          nextLessonId: nextLessonId,
          streakUpdated: false,
        );
      }
      rethrow;
    }
  }

  Future<LearningPathDetail> _buildPathDetailFromSkillLessons({
    required String level,
    required String pathId,
  }) async {
    final hub = await getHub(level: level);
    final matchingPaths = hub.paths.where((item) => item.id == pathId);
    final path = matchingPaths.isNotEmpty
        ? matchingPaths.first
        : LearningPath(
            id: pathId,
            level: level,
            title: 'Learning path',
            description: '',
            order: 0,
            status: 'available',
            progress: 0,
            activityCount: 0,
            completedActivityCount: 0,
            skillsCoverage: const [],
          );

    final lessonsBySkill = await Future.wait(
      _skills.map((skill) => _safeSkillLessons(level: level, skill: skill)),
    );
    final skillOrder = {for (var i = 0; i < _skills.length; i++) _skills[i]: i};
    final activities =
        <LearningPathActivity>[
          for (final skillLessons in lessonsBySkill)
            for (final lesson in skillLessons.lessons)
              if (lesson.unitId == pathId)
                LearningPathActivity.fromLesson(
                  lesson: lesson,
                  skill: skillLessons.skill,
                ),
        ]..sort((a, b) {
          final byOrder = a.order.compareTo(b.order);
          if (byOrder != 0) return byOrder;
          return (skillOrder[a.skill] ?? 99).compareTo(
            skillOrder[b.skill] ?? 99,
          );
        });

    return LearningPathDetail(
      id: path.id,
      level: path.level.isEmpty ? level : path.level,
      title: path.title,
      description: path.description,
      status: path.status,
      progress: path.progress,
      requiredScoreToPass: 70,
      activities: activities,
    );
  }

  Future<LearningSkillLessons> _safeSkillLessons({
    required String level,
    required String skill,
  }) async {
    try {
      return await getSkillLessons(level: level, skill: skill);
    } catch (_) {
      return LearningSkillLessons(
        level: level,
        skill: skill,
        title: skill,
        description: '',
        lessons: const [],
      );
    }
  }
}

const _skills = ['listening', 'speaking', 'reading', 'writing'];

LearningHub _withDemoPaths(LearningHub hub) {
  if (hub.paths.length >= 10) return hub;

  final existingIds = hub.paths.map((path) => path.id).toSet();
  final demoPaths = _demoPathTemplates(
    hub.selectedLevel,
  ).where((path) => !existingIds.contains(path.id)).toList(growable: false);

  return LearningHub(
    currentLevel: hub.currentLevel,
    selectedLevel: hub.selectedLevel,
    levels: hub.levels,
    skillTracks: hub.skillTracks,
    units: hub.units,
    supportTracks: _supportTracksWithTest(hub.supportTracks),
    paths: [...hub.paths, ...demoPaths],
    nextRecommendedSkill: hub.nextRecommendedSkill,
    dailyGoal: hub.dailyGoal,
    currentPathId: hub.currentPathId,
  );
}

List<LearningSupportTrack> _supportTracksWithTest(
  List<LearningSupportTrack> tracks,
) {
  final base = tracks.isEmpty ? _demoSupportTracks() : tracks;
  if (base.any((track) => track.type == 'test')) return base;
  return [...base, _testSupportTrack()];
}

List<LearningSupportTrack> _demoSupportTracks() {
  return [
    const LearningSupportTrack(
      type: 'grammar',
      title: 'Ngữ pháp',
      description: 'Ôn cấu trúc câu, thì và mẫu ngữ pháp quan trọng.',
      route: '/learn/grammar',
      progress: 0,
      enabled: true,
    ),
    const LearningSupportTrack(
      type: 'vocabulary',
      title: 'Từ vựng',
      description: 'Học từ theo chủ đề và lưu lại các từ cần ôn.',
      route: '/vocabulary',
      progress: 0,
      enabled: true,
    ),
    const LearningSupportTrack(
      type: 'flashcard',
      title: 'Flashcard',
      description: 'Ôn nhanh các bộ thẻ và củng cố từ đã học.',
      route: '/learn/flashcards',
      progress: 0,
      enabled: true,
    ),
    _testSupportTrack(),
  ];
}

LearningSupportTrack _testSupportTrack() {
  return const LearningSupportTrack(
    type: 'test',
    title: 'Kiểm tra',
    description: 'Làm bài kiểm tra theo chủ đề và cấp độ CEFR.',
    route: '/test',
    progress: 0,
    enabled: true,
  );
}

List<LearningPath> _demoPathTemplates(String level) {
  final topics = switch (level.toUpperCase()) {
    'A2' => const [
      (
        'plans',
        'Plans and invitations',
        'Make plans, invite people, and answer simple schedules.',
      ),
      (
        'travel',
        'Travel basics',
        'Ask for directions, book rooms, and handle tickets.',
      ),
      (
        'shopping',
        'Shopping choices',
        'Compare prices, sizes, and simple product details.',
      ),
      (
        'health',
        'Health and appointments',
        'Describe symptoms and arrange a short appointment.',
      ),
      (
        'work',
        'Work routines',
        'Talk about jobs, tasks, and workplace habits.',
      ),
      (
        'past-events',
        'Past events',
        'Tell short stories about yesterday or last weekend.',
      ),
      (
        'weather',
        'Weather and seasons',
        'Understand forecasts and describe seasonal plans.',
      ),
      (
        'city-life',
        'City life',
        'Use transport, places, and local service language.',
      ),
      (
        'food',
        'Eating out',
        'Order food, ask about ingredients, and review meals.',
      ),
      (
        'review',
        'A2 spiral review',
        'Mix the strongest patterns from all A2 topics.',
      ),
    ],
    'B1' => const [
      (
        'opinions',
        'Giving opinions',
        'Explain preferences, reasons, and simple disagreement.',
      ),
      (
        'stories',
        'Personal stories',
        'Narrate events with sequence and detail.',
      ),
      (
        'study-work',
        'Study and work goals',
        'Discuss plans, progress, and challenges.',
      ),
      (
        'media',
        'News and media',
        'Read short reports and summarize key points.',
      ),
      (
        'problem-solving',
        'Solving problems',
        'Describe issues and suggest practical solutions.',
      ),
      (
        'culture',
        'Culture and customs',
        'Compare habits and explain cultural experiences.',
      ),
      (
        'technology',
        'Everyday technology',
        'Talk about apps, devices, and online safety.',
      ),
      (
        'environment',
        'Local environment',
        'Discuss simple environmental actions.',
      ),
      (
        'interviews',
        'Interview practice',
        'Answer common study and job interview prompts.',
      ),
      (
        'review',
        'B1 fluency review',
        'Combine opinion, story, and problem-solving tasks.',
      ),
    ],
    'B2' => const [
      (
        'debate',
        'Structured debate',
        'Build arguments, examples, and counterpoints.',
      ),
      (
        'academic',
        'Academic reading',
        'Extract claims, evidence, and author purpose.',
      ),
      (
        'presentations',
        'Short presentations',
        'Plan and deliver clear topic presentations.',
      ),
      (
        'workplace',
        'Workplace communication',
        'Write updates, reports, and meeting notes.',
      ),
      (
        'social-issues',
        'Social issues',
        'Discuss causes, effects, and possible responses.',
      ),
      (
        'data',
        'Charts and data',
        'Describe trends, comparisons, and conclusions.',
      ),
      (
        'negotiation',
        'Negotiation',
        'Make offers, clarify terms, and reach agreement.',
      ),
      (
        'reviews',
        'Critical reviews',
        'Review films, products, and services with nuance.',
      ),
      ('exam', 'B2 exam tasks', 'Practice integrated exam-style tasks.'),
      (
        'review',
        'B2 integrated review',
        'Mix advanced listening, speaking, reading, and writing.',
      ),
    ],
    _ => const [
      (
        'greetings',
        'Greetings and introductions',
        'Say hello, ask names, and introduce yourself.',
      ),
      (
        'family',
        'Family and friends',
        'Talk about people, relationships, and basic descriptions.',
      ),
      (
        'daily-life',
        'Daily life',
        'Describe routines, times, and simple habits.',
      ),
      (
        'classroom',
        'Classroom English',
        'Follow classroom instructions and ask for help.',
      ),
      (
        'food-drink',
        'Food and drinks',
        'Order simple food and talk about likes.',
      ),
      (
        'home',
        'My home',
        'Name rooms, furniture, and describe where things are.',
      ),
      (
        'places',
        'Places in town',
        'Ask about familiar places and simple directions.',
      ),
      (
        'free-time',
        'Free time',
        'Talk about hobbies, sports, and weekend activities.',
      ),
      (
        'shopping',
        'Simple shopping',
        'Ask prices, colors, sizes, and quantities.',
      ),
      (
        'review',
        'A1 mixed review',
        'Review core A1 patterns across all skills.',
      ),
    ],
  };

  return [
    for (var i = 0; i < topics.length; i++)
      LearningPath(
        id: '${level.toLowerCase()}-demo-path-${(i + 1).toString().padLeft(2, '0')}-${topics[i].$1}',
        level: level,
        title: topics[i].$2,
        description: topics[i].$3,
        order: i + 1,
        status: i == 0
            ? 'in_progress'
            : i < 4
            ? 'available'
            : 'locked',
        progress: i == 0
            ? 0.38
            : i < 2
            ? 0.12
            : 0,
        activityCount: 8,
        completedActivityCount: i == 0
            ? 3
            : i < 2
            ? 1
            : 0,
        skillsCoverage: const [
          'vocabulary',
          'listening',
          'reading',
          'grammar',
          'speaking',
          'writing',
        ],
      ),
  ];
}

LearningPathDetail _demoPathDetail(String level, String pathId) {
  final path = _demoPathTemplates(level).where((item) => item.id == pathId);
  final selected = path.isNotEmpty
      ? path.first
      : LearningPath(
          id: pathId,
          level: level,
          title: 'Demo learning path',
          description:
              'Mixed activities across vocabulary, listening, reading, grammar, speaking, and writing.',
          order: 0,
          status: 'available',
          progress: 0,
          activityCount: 8,
          completedActivityCount: 0,
          skillsCoverage: const [],
        );

  final activities = [
    (
      'vocabulary',
      'vocabulary_match',
      'Vocabulary warm-up',
      'Learn key words and chunks for this topic.',
      5,
      8,
    ),
    (
      'listening',
      'listening_choice',
      'Listen for main ideas',
      'Hear a short dialog and choose the correct meaning.',
      7,
      10,
    ),
    (
      'reading',
      'reading_question',
      'Read a short text',
      'Find details and simple inference in context.',
      8,
      10,
    ),
    (
      'grammar',
      'grammar_fill_blank',
      'Grammar in context',
      'Use the target sentence pattern from the topic.',
      6,
      8,
    ),
    (
      'speaking',
      'pronunciation',
      'Speak in the situation',
      'Record a short answer using the topic language.',
      7,
      12,
    ),
    (
      'writing',
      'writing_prompt',
      'Write a short response',
      'Write a few sentences connected to the topic.',
      9,
      12,
    ),
    (
      'listening',
      'multiple_choice',
      'Listen for details',
      'Catch names, numbers, places, or reasons.',
      7,
      10,
    ),
    (
      'writing',
      'review_quiz',
      'Mixed review',
      'Finish the path with a short integrated review.',
      10,
      15,
    ),
  ];

  return LearningPathDetail(
    id: selected.id,
    level: selected.level,
    title: selected.title,
    description: selected.description,
    status: selected.status,
    progress: selected.progress,
    requiredScoreToPass: 70,
    activities: [
      for (var i = 0; i < activities.length; i++)
        LearningPathActivity(
          id: '${selected.id}-act-${(i + 1).toString().padLeft(2, '0')}',
          pathId: selected.id,
          title: activities[i].$3,
          subtitle: activities[i].$4,
          skill: activities[i].$1,
          type: activities[i].$2,
          status: i < selected.completedActivityCount
              ? 'completed'
              : i == selected.completedActivityCount
              ? 'available'
              : 'locked',
          order: i + 1,
          durationMinutes: activities[i].$5,
          xpReward: activities[i].$6,
        ),
    ],
  );
}

bool _isDemoActivityId(String id) {
  return id.contains('-demo-path-') && id.contains('-act-');
}

bool _isDemoPathId(String id) {
  return id.contains('-demo-path-');
}

String? _nextDemoActivityId(String lessonId) {
  final parts = lessonId.split('-act-');
  if (parts.length != 2) return null;
  final currentOrder = int.tryParse(parts.last);
  if (currentOrder == null || currentOrder >= 8) return null;
  return '${parts.first}-act-${(currentOrder + 1).toString().padLeft(2, '0')}';
}

LearningLessonDetail _demoLessonDetail(String lessonId) {
  final pathId = lessonId.split('-act-').first;
  final orderText = lessonId.split('-act-').last;
  final order = int.tryParse(orderText) ?? 1;
  final level = pathId.split('-').first.toUpperCase();
  final path = _demoPathTemplates(level).where((item) => item.id == pathId);
  final selectedPath = path.isNotEmpty
      ? path.first
      : LearningPath(
          id: pathId,
          level: level,
          title: 'Demo learning path',
          description: 'Mixed practice path',
          order: 0,
          status: 'available',
          progress: 0,
          activityCount: 8,
          completedActivityCount: 0,
          skillsCoverage: const [],
        );
  final activity = _demoPathDetail(level, pathId).activities.firstWhere(
    (item) => item.id == lessonId,
    orElse: () => _demoPathDetail(level, pathId).activities.first,
  );

  final content = switch (activity.skill) {
    'listening' => {
      'instruction':
          'Listen to a short dialog from "${selectedPath.title}" and answer the question.',
      'transcript': 'A: Hello, I am Mai. B: Nice to meet you, Mai.',
      'translationVi': 'Hoi thoai ngan theo chu de ${selectedPath.title}.',
    },
    'reading' => {
      'instruction': 'Read the short text and choose the best answer.',
      'passage':
          'My name is Ben. I live near the school. On weekends, I play football with my friends.',
      'translationVi': 'Doan doc ngan theo chu de ${selectedPath.title}.',
    },
    'speaking' => {
      'instruction': 'Listen to the model, then record your own answer.',
      'sampleText': 'Hello, my name is Linh.',
      'phonetic': 'hello, my name is Linh',
      'translationVi': 'Luyen noi theo tinh huong cua path.',
    },
    'writing' => {
      'instruction': 'Write a short response connected to the topic.',
      'prompt':
          'Write 2-3 sentences about ${selectedPath.title.toLowerCase()}.',
      'exampleAnswer': 'My name is Mai. I like learning English every day.',
    },
    _ => {
      'instruction': 'Practice useful language from "${selectedPath.title}".',
      'translationVi': 'Bai tap mau de xem flow hoc theo path.',
    },
  };

  return LearningLessonDetail(
    id: lessonId,
    level: selectedPath.level,
    skill: activity.skill,
    unitId: pathId,
    title: activity.title,
    subtitle: activity.subtitle,
    durationMinutes: activity.durationMinutes,
    xpReward: activity.xpReward,
    status: activity.status,
    content: content,
    activities: [_demoLearningActivity(activity, order)],
  );
}

LearningActivity _demoLearningActivity(
  LearningPathActivity activity,
  int order,
) {
  if (activity.skill == 'speaking') {
    return LearningActivity.fromJson({
      'id': 'demo-act-$order',
      'type': 'pronunciation',
      'expectedText': 'Hello, my name is Linh.',
      'minScoreToPass': 70,
    });
  }
  if (activity.skill == 'writing') {
    return LearningActivity.fromJson({
      'id': 'demo-act-$order',
      'type': 'writing_prompt',
      'prompt': activity.subtitle,
      'rubric': [
        'Answer the prompt clearly.',
        'Use vocabulary from the path.',
        'Write complete sentences.',
      ],
    });
  }
  return LearningActivity.fromJson({
    'id': 'demo-act-$order',
    'type': 'multiple_choice',
    'question': 'Which answer best matches this activity?',
    'options': [
      {'id': 'A', 'text': activity.subtitle},
      {'id': 'B', 'text': 'An unrelated answer'},
      {'id': 'C', 'text': 'Skip this topic'},
    ],
    'correctOptionId': 'A',
    'explanationVi': 'Dap an A dung voi muc tieu cua activity nay.',
  });
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return const {};
}
