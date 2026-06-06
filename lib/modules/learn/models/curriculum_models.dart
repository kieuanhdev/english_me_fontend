// Models cho luồng giáo trình mới (Unit → Lesson → Theory/Practice/Quiz).
// Tách khỏi learning_models.dart để không đụng module cũ.

import 'package:englishme/modules/learn/models/learning_models.dart' show XpBonus;

class LevelUnits {
  LevelUnits({
    required this.level,
    required this.levelProgress,
    required this.completedUnits,
    required this.totalUnits,
    required this.checkpointUnlocked,
    required this.units,
  });

  final String level;
  final double levelProgress;
  final int completedUnits;
  final int totalUnits;
  final bool checkpointUnlocked;
  final List<CurriculumUnit> units;

  factory LevelUnits.fromJson(Map<String, dynamic> json) => LevelUnits(
        level: (json['level'] ?? 'A1').toString(),
        levelProgress: _d(json['levelProgress']),
        completedUnits: _i(json['completedUnits']),
        totalUnits: _i(json['totalUnits']),
        checkpointUnlocked: json['checkpointUnlocked'] == true,
        units: _list(json['units'], CurriculumUnit.fromJson),
      );
}

class CurriculumUnit {
  CurriculumUnit({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.order,
    required this.status, // locked | available | in_progress | completed
    required this.lessonCount,
    required this.completedLessonCount,
    required this.skillCoverage,
  });

  final String id;
  final String level;
  final String title;
  final String subtitle;
  final int order;
  final String status;
  final int lessonCount;
  final int completedLessonCount;
  final List<String> skillCoverage;

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';
  double get progress =>
      lessonCount == 0 ? 0 : (completedLessonCount / lessonCount).clamp(0, 1).toDouble();

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) => CurriculumUnit(
        id: (json['id'] ?? '').toString(),
        level: (json['level'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        order: _i(json['order']),
        status: (json['status'] ?? 'available').toString(),
        lessonCount: _i(json['lessonCount']),
        completedLessonCount: _i(json['completedLessonCount']),
        skillCoverage: ((json['skillCoverage'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class UnitDetail {
  UnitDetail({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.completedLessonCount,
    required this.totalLessons,
    required this.lessons,
  });

  final String id;
  final String level;
  final String title;
  final String subtitle;
  final String status;
  final int completedLessonCount;
  final int totalLessons;
  final List<LessonListItem> lessons;

  factory UnitDetail.fromJson(Map<String, dynamic> json) => UnitDetail(
        id: (json['id'] ?? '').toString(),
        level: (json['level'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        status: (json['status'] ?? 'available').toString(),
        completedLessonCount: _i(json['completedLessonCount']),
        totalLessons: _i(json['totalLessons']),
        lessons: _list(json['lessons'], LessonListItem.fromJson),
      );
}

class LessonListItem {
  LessonListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.skill,
    required this.order,
    required this.status,
    required this.theoryViewed,
    required this.bestScore,
    required this.xpReward,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final String subtitle;
  final String skill;
  final int order;
  final String status;
  final bool theoryViewed;
  final int bestScore;
  final int xpReward;
  final int durationMinutes;

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';

  factory LessonListItem.fromJson(Map<String, dynamic> json) => LessonListItem(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        skill: (json['skill'] ?? '').toString(),
        order: _i(json['lessonOrder'] ?? json['order']),
        status: (json['status'] ?? 'available').toString(),
        theoryViewed: json['theoryViewed'] == true,
        bestScore: _i(json['bestScore']),
        xpReward: _i(json['xpReward']),
        durationMinutes: _i(json['durationMinutes']),
      );
}

class CurriculumLessonDetail {
  CurriculumLessonDetail({
    required this.id,
    required this.unitId,
    required this.level,
    required this.skill,
    required this.title,
    required this.subtitle,
    required this.xpReward,
    required this.requiredScoreToPass,
    required this.theoryViewed,
    required this.practiceCompleted,
    required this.status,
    required this.theory,
    required this.exercises,
    required this.quiz,
  });

  final String id;
  final String unitId;
  final String level;
  final String skill;
  final String title;
  final String subtitle;
  final int xpReward;
  final int requiredScoreToPass;
  final bool theoryViewed;
  final bool practiceCompleted; // đã xong luyện tập → vào thẳng quiz
  final String status;          // locked | available | in_progress | completed
  final LessonTheory theory;
  final List<CurriculumActivity> exercises; // phase=practice
  final List<CurriculumActivity> quiz;       // phase=quiz

  bool get isCompleted => status == 'completed';

  factory CurriculumLessonDetail.fromJson(Map<String, dynamic> json) =>
      CurriculumLessonDetail(
        id: (json['id'] ?? '').toString(),
        unitId: (json['unitId'] ?? '').toString(),
        level: (json['level'] ?? '').toString(),
        skill: (json['skill'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        xpReward: _i(json['xpReward']),
        requiredScoreToPass: json['requiredScoreToPass'] == null
            ? 70
            : _i(json['requiredScoreToPass']),
        theoryViewed: json['theoryViewed'] == true,
        practiceCompleted: json['practiceCompleted'] == true,
        status: (json['status'] ?? 'available').toString(),
        theory: LessonTheory.fromJson(
            (json['theory'] as Map<String, dynamic>?) ?? const {}),
        exercises: _list(json['exercises'], CurriculumActivity.fromJson),
        quiz: _list(json['quiz'], CurriculumActivity.fromJson),
      );
}

class LessonTheory {
  LessonTheory({
    required this.warmup,
    required this.objectives,
    required this.vocabBlock,
    required this.examples,
    required this.commonMistakes,
    required this.tips,
    this.grammarHtml,
  });

  final String warmup;
  final List<String> objectives;
  final List<VocabItem> vocabBlock;
  final List<ExampleItem> examples;
  final List<String> commonMistakes;
  final List<String> tips;
  final String? grammarHtml; // bảng/giải thích ngữ pháp (text), null nếu lesson vocab

  factory LessonTheory.fromJson(Map<String, dynamic> json) => LessonTheory(
        warmup: (json['warmup'] ?? '').toString(),
        objectives: ((json['objectives'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        vocabBlock: _list(json['vocabBlock'], VocabItem.fromJson),
        examples: _list(json['examples'], ExampleItem.fromJson),
        commonMistakes: ((json['commonMistakes'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        tips: ((json['tips'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        grammarHtml: json['grammarHtml']?.toString(),
      );
}

class VocabItem {
  VocabItem({
    required this.word,
    required this.ipa,
    required this.meaningVi,
    required this.example,
  });
  final String word, ipa, meaningVi, example;
  factory VocabItem.fromJson(Map<String, dynamic> j) => VocabItem(
        word: (j['word'] ?? '').toString(),
        ipa: (j['ipa'] ?? '').toString(),
        meaningVi: (j['meaningVi'] ?? '').toString(),
        example: (j['example'] ?? '').toString(),
      );
}

class ExampleItem {
  ExampleItem({required this.en, required this.vi});
  final String en, vi;
  factory ExampleItem.fromJson(Map<String, dynamic> j) =>
      ExampleItem(en: (j['en'] ?? '').toString(), vi: (j['vi'] ?? '').toString());
}

class CurriculumActivity {
  CurriculumActivity({
    required this.id,
    required this.type,
    required this.phase, // practice | quiz
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.explanationVi,
    required this.acceptedAnswers,
    required this.pairs,
    required this.tokens,
    required this.correctOrder,
    required this.audioText,
    required this.targetText,
    required this.ipa,
    required this.minScoreToPass,
    required this.sourceText,
  });

  /// Các loại bài tập hỗ trợ.
  /// MVP: multiple_choice | grammar_fill_blank | vocabulary_match
  /// Mở rộng: sentence_ordering | listening_choice | pronunciation |
  ///          translation | error_correction
  final String id;
  final String type;
  final String phase;
  final String difficulty;
  final String question;
  final List<ActivityOption> options; // multiple_choice | listening_choice
  final String correctOptionId; // multiple_choice | listening_choice
  final String explanationVi;
  final List<String> acceptedAnswers; // fill_blank | translation | error_correction
  final List<MatchPair> pairs; // vocabulary_match: cặp trái↔phải

  // sentence_ordering: tokens xáo trộn + thứ tự đúng (theo index của tokens gốc).
  final List<String> tokens;
  final List<int> correctOrder;

  // listening_choice: text để TTS đọc (không hiển thị cho người học).
  final String audioText;

  // pronunciation: câu/từ cần đọc + phiên âm + ngưỡng điểm tối thiểu.
  final String targetText;
  final String ipa;
  final int minScoreToPass;

  // translation / error_correction: câu nguồn (en hoặc câu sai cần sửa).
  final String sourceText;

  bool get isMcq => type == 'multiple_choice';
  bool get isFillBlank => type == 'grammar_fill_blank';
  bool get isMatch => type == 'vocabulary_match';
  bool get isOrdering => type == 'sentence_ordering';
  bool get isListening => type == 'listening_choice';
  bool get isPronunciation => type == 'pronunciation';
  bool get isTranslation => type == 'translation';
  bool get isErrorCorrection => type == 'error_correction';

  /// Dạng nhập đáp án bằng text tự do (chấm theo acceptedAnswers).
  bool get isTextInput => isFillBlank || isTranslation || isErrorCorrection;

  factory CurriculumActivity.fromJson(Map<String, dynamic> json) =>
      CurriculumActivity(
        id: (json['id'] ?? '').toString(),
        type: (json['type'] ?? 'multiple_choice').toString(),
        phase: (json['phase'] ?? 'quiz').toString(),
        difficulty: (json['difficulty'] ?? 'medium').toString(),
        question: (json['question'] ?? json['prompt'] ?? '').toString(),
        options: _list(json['options'], ActivityOption.fromJson),
        correctOptionId: (json['correctOptionId'] ?? '').toString(),
        explanationVi: (json['explanationVi'] ?? '').toString(),
        acceptedAnswers: ((json['acceptedAnswers'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        pairs: _list(json['pairs'], MatchPair.fromJson),
        tokens: ((json['tokens'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        correctOrder: ((json['correctOrder'] as List?) ?? const [])
            .map(_i)
            .toList(),
        audioText: (json['audioText'] ?? '').toString(),
        targetText: (json['targetText'] ?? '').toString(),
        ipa: (json['ipa'] ?? '').toString(),
        minScoreToPass:
            json['minScoreToPass'] == null ? 70 : _i(json['minScoreToPass']),
        sourceText: (json['sourceText'] ?? '').toString(),
      );
}

class ActivityOption {
  ActivityOption({required this.id, required this.text});
  final String id, text;
  factory ActivityOption.fromJson(Map<String, dynamic> j) =>
      ActivityOption(id: (j['id'] ?? '').toString(), text: (j['text'] ?? '').toString());
}

// Cặp ghép cho vocabulary_match (vd left='dog' ↔ right='con chó')
class MatchPair {
  MatchPair({required this.left, required this.right});
  final String left, right;
  factory MatchPair.fromJson(Map<String, dynamic> j) =>
      MatchPair(left: (j['left'] ?? '').toString(), right: (j['right'] ?? '').toString());
}

// Kết quả nộp quiz
class LessonResult {
  LessonResult({
    required this.passed,
    required this.score,
    required this.xpEarned,
    required this.unitProgress,
    required this.unitCompleted,
    required this.nextLessonId,
    this.totalXp = 0,
    this.dailyEarnedXp = 0,
    this.streakUpdated = false,
    this.bonuses = const [],
  });
  final bool passed;
  final int score;
  final int xpEarned;
  final double unitProgress;
  final bool unitCompleted;
  final String? nextLessonId;

  // ── XP grant info (để FE đồng bộ Profile/Home/Progress + ăn mừng bonus) ──
  final int totalXp;
  final int dailyEarnedXp;
  final bool streakUpdated;
  final List<XpBonus> bonuses;
}

// ── Level Checkpoint Test (lên cấp CEFR) ──
class CheckpointState {
  CheckpointState({
    required this.level,
    required this.nextLevel,
    required this.title,
    required this.unlocked,
    required this.unitProgress,
    required this.requiredUnitProgress,
    required this.passScore,
    required this.alreadyPassed,
    required this.questions,
  });

  final String level;
  final String? nextLevel;
  final String title;
  final bool unlocked;
  final double unitProgress;
  final double requiredUnitProgress;
  final int passScore;
  final bool alreadyPassed;
  final List<CurriculumActivity> questions; // câu hỏi (đã ẩn đáp án đúng — BE chấm)

  factory CheckpointState.fromJson(Map<String, dynamic> json) => CheckpointState(
        level: (json['level'] ?? '').toString(),
        nextLevel: json['nextLevel']?.toString(),
        title: (json['title'] ?? '').toString(),
        unlocked: json['unlocked'] == true,
        unitProgress: _d(json['unitProgress']),
        requiredUnitProgress: _d(json['requiredUnitProgress']),
        passScore: json['passScore'] == null ? 75 : _i(json['passScore']),
        alreadyPassed: json['alreadyPassed'] == true,
        questions: _list(json['questions'], CurriculumActivity.fromJson),
      );
}

class CheckpointResult {
  CheckpointResult({
    required this.passed,
    required this.score,
    required this.passScore,
    required this.leveledUp,
    required this.fromLevel,
    required this.toLevel,
    required this.xpEarned,
  });

  final bool passed;
  final int score;
  final int passScore;
  final bool leveledUp;
  final String fromLevel;
  final String? toLevel;
  final int xpEarned;

  factory CheckpointResult.fromJson(Map<String, dynamic> json) => CheckpointResult(
        passed: json['passed'] == true,
        score: _i(json['score']),
        passScore: _i(json['passScore']),
        leveledUp: json['leveledUp'] == true,
        fromLevel: (json['fromLevel'] ?? '').toString(),
        toLevel: json['toLevel']?.toString(),
        xpEarned: _i(json['xpEarned']),
      );
}

// ── helpers ──
int _i(dynamic v) => v is int ? v : (v is num ? v.round() : int.tryParse('${v ?? ''}') ?? 0);
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) f) =>
    (v is List ? v : const [])
        .whereType<Map<String, dynamic>>()
        .map(f)
        .toList(growable: false);
