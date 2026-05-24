import 'vocab_level.dart';

/// Unified word model — covers both topic-based (VocabularyWord) and
/// desk-based flashcard (FlashcardModel) data sources.
class VocabWord {
  final String id;
  final String deskId;   // empty when sourced from topic
  final String topicId;  // empty when sourced from desk
  final String word;
  final String ipa;
  final List<String> pos;
  final String audioUrl;
  final String definitionEn;
  final String definitionVi;
  final String exampleSentence;
  final String exampleTranslation;
  final VocabLevel level;

  const VocabWord({
    required this.id,
    this.deskId = '',
    this.topicId = '',
    required this.word,
    required this.ipa,
    required this.pos,
    required this.audioUrl,
    required this.definitionEn,
    required this.definitionVi,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.level,
  });

  /// From topic API: GET /vocabulary/topics/{id}/words
  factory VocabWord.fromTopicJson(Map<String, dynamic> json, {String topicId = ''}) =>
      VocabWord(
        id: (json['id'] ?? '').toString(),
        topicId: (json['topicId'] ?? topicId).toString(),
        word: (json['word'] ?? '').toString(),
        ipa: (json['pronunciation'] ?? json['ipa'] ?? '').toString(),
        pos: _toStringList(json['partOfSpeech']),
        audioUrl: (json['audioUrl'] ?? '').toString(),
        definitionEn: (json['definitionEn'] ?? json['definition'] ?? '').toString(),
        definitionVi: (json['definitionVi'] ?? json['vietnamese'] ?? json['viDefinition'] ?? '').toString(),
        exampleSentence: (json['exampleSentence'] ?? json['example'] ?? '').toString(),
        exampleTranslation: (json['exampleTranslation'] ?? json['viExample'] ?? '').toString(),
        level: VocabLevelX.fromString(json['level'] as String?),
      );

  /// From desk flashcard API: GET /desks/{id}/flashcards
  factory VocabWord.fromFlashcardJson(Map<String, dynamic> json) => VocabWord(
        id: _firstString(json, const ['id', 'flashcardId', 'cardId']),
        deskId: _firstString(json, const ['deskId', 'desk_id']),
        word: (json['word'] ?? '').toString(),
        ipa: (json['ipa'] ?? '').toString(),
        pos: _toStringList(json['pos']),
        audioUrl: (json['audioUrl'] ?? '').toString(),
        definitionEn: (json['definition'] ?? '').toString(),
        definitionVi: (json['viDefinition'] ?? json['vietnamese'] ?? '').toString(),
        exampleSentence: (json['example'] ?? '').toString(),
        exampleTranslation: (json['viExample'] ?? '').toString(),
        level: VocabLevelX.fromString(json['cefr'] as String?),
      );

  String resolvedAudioUrl(String baseUrl) {
    if (audioUrl.isEmpty) return '';
    if (audioUrl.startsWith('http')) return audioUrl;
    return '$baseUrl/$audioUrl';
  }

  String get partOfSpeech => pos.join(', ');
}

// ─── Pagination wrapper (for desk flashcards) ─────────────────────────────────

class VocabWordPage {
  final List<VocabWord> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final bool last;

  const VocabWordPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.last,
  });

  factory VocabWordPage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final content = rawContent is List
        ? rawContent
            .whereType<Map<String, dynamic>>()
            .map(VocabWord.fromFlashcardJson)
            .toList()
        : <VocabWord>[];
    return VocabWordPage(
      content: content,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? content.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      number: (json['number'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}

// ─── Spelling result ──────────────────────────────────────────────────────────

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

enum SpellingState { idle, typing, correct, wrong }

// ─── Helpers ──────────────────────────────────────────────────────────────────

List<String> _toStringList(dynamic value) {
  if (value is List) return value.whereType<Object>().map((e) => e.toString()).toList();
  if (value is String && value.trim().isNotEmpty) return [value.trim()];
  return const [];
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = (json[key]?.toString() ?? '').trim();
    if (v.isNotEmpty) return v;
  }
  return '';
}
