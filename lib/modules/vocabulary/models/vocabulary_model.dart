enum VocabularyLevel { a1, a2, b1, b2, c1, c2 }

extension VocabularyLevelX on VocabularyLevel {
  static VocabularyLevel fromCefr(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'A1':
        return VocabularyLevel.a1;
      case 'A2':
        return VocabularyLevel.a2;
      case 'B1':
        return VocabularyLevel.b1;
      case 'B2':
        return VocabularyLevel.b2;
      case 'C1':
        return VocabularyLevel.c1;
      case 'C2':
        return VocabularyLevel.c2;
      default:
        return VocabularyLevel.a1;
    }
  }
}

enum SpellingState { idle, listening, typing, correct, wrong }

class VocabularyTopic {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final int wordCount;
  final VocabularyLevel level;
  final String colorHex;

  const VocabularyTopic({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.wordCount,
    required this.level,
    required this.colorHex,
  });

  factory VocabularyTopic.fromJson(Map<String, dynamic> json) {
    return VocabularyTopic(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? '').toString(),
      icon: (json['icon'] ?? '📚').toString(),
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      level: VocabularyLevelX.fromCefr(json['level'] as String?),
      colorHex: (json['colorHex'] ?? '#4CAF50').toString(),
    );
  }
}

class VocabularyWord {
  final String id;
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definitionVi;
  final String definitionEn;
  final String exampleSentence;
  final String exampleTranslation;
  final VocabularyLevel level;
  final String topicId;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definitionVi,
    required this.definitionEn,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.level,
    required this.topicId,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json, {String topicId = ''}) {
    return VocabularyWord(
      id: (json['id'] ?? '').toString(),
      word: (json['word'] ?? '').toString(),
      pronunciation: (json['pronunciation'] ?? '').toString(),
      partOfSpeech: (json['partOfSpeech'] ?? '').toString(),
      definitionVi: (json['definitionVi'] ?? '').toString(),
      definitionEn: (json['definitionEn'] ?? '').toString(),
      exampleSentence: (json['exampleSentence'] ?? '').toString(),
      exampleTranslation: (json['exampleTranslation'] ?? '').toString(),
      level: VocabularyLevelX.fromCefr(json['level'] as String?),
      topicId: (json['topicId'] ?? topicId).toString(),
    );
  }
}

class SpellingResult {
  final String wordId;
  final String word;
  final String userInput;
  final bool isCorrect;

  const SpellingResult({
    required this.wordId,
    required this.word,
    required this.userInput,
    required this.isCorrect,
  });
}
