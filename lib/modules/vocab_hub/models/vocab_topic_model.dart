import 'vocab_level.dart';

class VocabTopic {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final int wordCount;
  final VocabLevel level;
  final String colorHex;

  const VocabTopic({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.wordCount,
    required this.level,
    required this.colorHex,
  });

  factory VocabTopic.fromJson(Map<String, dynamic> json) => VocabTopic(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        nameEn: (json['nameEn'] ?? '').toString(),
        icon: (json['icon'] ?? '📚').toString(),
        wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
        level: VocabLevelX.fromString(json['level'] as String?),
        colorHex: (json['colorHex'] ?? '#4CAF50').toString(),
      );
}
