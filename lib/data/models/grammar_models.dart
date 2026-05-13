class GrammarTopic {
  const GrammarTopic({
    required this.id,
    required this.slug,
    required this.category,
    required this.level,
    required this.title,
    required this.sortOrder,
    required this.lessonCount,
  });

  final String id;
  final String slug;
  final String category;
  final String level;
  final String title;
  final int sortOrder;
  final int lessonCount;

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      lessonCount: (json['lessonCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class GrammarLessonListItem {
  const GrammarLessonListItem({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.sortOrder,
  });

  final String id;
  final String sourceId;
  final String title;
  final int sortOrder;

  factory GrammarLessonListItem.fromJson(Map<String, dynamic> json) {
    return GrammarLessonListItem(
      id: json['id']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class GrammarFormula {
  const GrammarFormula({required this.label, required this.structure});

  final String label;
  final String structure;

  factory GrammarFormula.fromJson(Map<String, dynamic> json) {
    return GrammarFormula(
      label: json['label']?.toString() ?? '',
      structure: json['structure']?.toString() ?? '',
    );
  }
}

class GrammarExample {
  const GrammarExample({
    required this.en,
    required this.vi,
    required this.note,
  });

  final String en;
  final String vi;
  final String note;

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      en: json['en']?.toString() ?? '',
      vi: json['vi']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}

class GrammarMistake {
  const GrammarMistake({
    required this.wrong,
    required this.correct,
    required this.explainVi,
  });

  final String wrong;
  final String correct;
  final String explainVi;

  factory GrammarMistake.fromJson(Map<String, dynamic> json) {
    return GrammarMistake(
      wrong: json['wrong']?.toString() ?? '',
      correct: json['correct']?.toString() ?? '',
      explainVi: json['explain_vi']?.toString() ?? '',
    );
  }
}

class GrammarExercise {
  const GrammarExercise({
    required this.id,
    required this.exerciseOrder,
    required this.exerciseType,
    required this.content,
  });

  final String id;
  final int exerciseOrder;
  final String exerciseType;
  final Map<String, dynamic> content;

  factory GrammarExercise.fromJson(Map<String, dynamic> json) {
    return GrammarExercise(
      id: json['id']?.toString() ?? '',
      exerciseOrder: (json['exerciseOrder'] as num?)?.toInt() ?? 0,
      exerciseType: json['exerciseType']?.toString() ?? '',
      content: (json['content'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

class GrammarLessonDetail {
  const GrammarLessonDetail({
    required this.id,
    required this.topicId,
    required this.sourceId,
    required this.title,
    required this.sortOrder,
    required this.explanationVi,
    required this.whenToUseVi,
    required this.tipsVi,
    required this.formulas,
    required this.keyWords,
    required this.examples,
    required this.commonMistakes,
    required this.exercises,
  });

  final String id;
  final String topicId;
  final String sourceId;
  final String title;
  final int sortOrder;
  final String explanationVi;
  final String whenToUseVi;
  final String tipsVi;
  final List<GrammarFormula> formulas;
  final List<String> keyWords;
  final List<GrammarExample> examples;
  final List<GrammarMistake> commonMistakes;
  final List<GrammarExercise> exercises;

  factory GrammarLessonDetail.fromJson(Map<String, dynamic> json) {
    return GrammarLessonDetail(
      id: json['id']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      explanationVi: json['explanationVi']?.toString() ?? '',
      whenToUseVi: json['whenToUseVi']?.toString() ?? '',
      tipsVi: json['tipsVi']?.toString() ?? '',
      formulas: ((json['formulas'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => GrammarFormula.fromJson(e.cast<String, dynamic>()))
          .toList(),
      keyWords: ((json['keyWords'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      examples: ((json['examples'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => GrammarExample.fromJson(e.cast<String, dynamic>()))
          .toList(),
      commonMistakes: ((json['commonMistakes'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => GrammarMistake.fromJson(e.cast<String, dynamic>()))
          .toList(),
      exercises: ((json['exercises'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => GrammarExercise.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}
