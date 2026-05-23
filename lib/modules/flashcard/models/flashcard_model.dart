class FlashcardModel {
  final String id;
  final String deskId;
  final String word;
  final String cefr;
  final List<String> pos;
  final String ipa;
  final String audioUrl;
  final String definition;
  final String example;
  final String topic;
  final String vietnamese;
  final String viDefinition;
  final String viExample;

  const FlashcardModel({
    required this.id,
    required this.deskId,
    required this.word,
    required this.cefr,
    required this.pos,
    required this.ipa,
    required this.audioUrl,
    required this.definition,
    required this.example,
    required this.topic,
    required this.vietnamese,
    required this.viDefinition,
    required this.viExample,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) => FlashcardModel(
        id: _firstString(json, const ['id', 'flashcardId', 'cardId']),
        deskId: _firstString(json, const ['deskId', 'desk_id']),
        word: _asString(json['word']),
        cefr: _asString(json['cefr']),
        pos: _asStringList(json['pos']),
        ipa: _asString(json['ipa']),
        audioUrl: _asString(json['audioUrl']),
        definition: _asString(json['definition']),
        example: _asString(json['example']),
        topic: _asString(json['topic']),
        vietnamese: _asString(json['vietnamese']),
        viDefinition: _asString(json['viDefinition']),
        viExample: _asString(json['viExample']),
      );

  String resolvedAudioUrl(String baseUrl) {
    if (audioUrl.isEmpty) return '';
    if (audioUrl.startsWith('http')) return audioUrl;
    return '$baseUrl/$audioUrl';
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _asString(json[key]).trim();
    if (value.isNotEmpty) return value;
  }
  return '';
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.where((e) => e != null).map((e) => e.toString()).toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }
  return const [];
}

class FlashcardPage {
  final List<FlashcardModel> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final bool last;

  const FlashcardPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.last,
  });

  factory FlashcardPage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final content = rawContent is List
        ? rawContent
              .whereType<Map<String, dynamic>>()
              .map(FlashcardModel.fromJson)
              .toList()
        : <FlashcardModel>[];

    return FlashcardPage(
      content: content,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? content.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      number: (json['number'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}
