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
        id: json['id'] as String,
        deskId: json['deskId'] as String,
        word: json['word'] as String,
        cefr: json['cefr'] as String,
        pos: (json['pos'] as List<dynamic>).map((e) => e as String).toList(),
        ipa: json['ipa'] as String? ?? '',
        audioUrl: json['audioUrl'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        example: json['example'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        vietnamese: json['vietnamese'] as String? ?? '',
        viDefinition: json['viDefinition'] as String? ?? '',
        viExample: json['viExample'] as String? ?? '',
      );

  String resolvedAudioUrl(String baseUrl) {
    if (audioUrl.isEmpty) return '';
    if (audioUrl.startsWith('http')) return audioUrl;
    return '$baseUrl/$audioUrl';
  }
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

  factory FlashcardPage.fromJson(Map<String, dynamic> json) => FlashcardPage(
        content: (json['content'] as List<dynamic>)
            .map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalElements: json['totalElements'] as int,
        totalPages: json['totalPages'] as int,
        number: json['number'] as int,
        last: json['last'] as bool,
      );
}
