class VocabDesk {
  final String id;
  final String cefrLevel;
  final String title;
  final int sortOrder;
  final String createdAt;
  final int flashcardCount;

  const VocabDesk({
    required this.id,
    required this.cefrLevel,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.flashcardCount,
  });

  factory VocabDesk.fromJson(Map<String, dynamic> json) => VocabDesk(
        id: json['id']?.toString() ?? '',
        cefrLevel: json['cefrLevel']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
        flashcardCount: (json['flashcardCount'] as num?)?.toInt() ?? 0,
      );
}
