enum VocabularyLevel { a1, a2, b1, b2, c1, c2 }

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
