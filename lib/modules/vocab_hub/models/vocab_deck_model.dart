class VocabDeck {
  final String id;
  final String cefrLevel;
  final String title;
  final int sortOrder;
  final String createdAt;
  final int flashcardCount;

  /// true = bộ thẻ hệ thống (owner=NULL ở backend). FE ẩn sửa/xoá, gắn nhãn "Hệ thống".
  final bool isSystem;

  const VocabDeck({
    required this.id,
    required this.cefrLevel,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.flashcardCount,
    this.isSystem = false,
  });

  factory VocabDeck.fromJson(Map<String, dynamic> json) => VocabDeck(
        id: json['id']?.toString() ?? '',
        cefrLevel: json['cefrLevel']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
        flashcardCount: (json['flashcardCount'] as num?)?.toInt() ?? 0,
        isSystem: json['isSystem'] == true,
      );
}

/// Tiến độ học SM-2 tóm tắt cho 1 bộ thẻ — suy ra từ due-cards + tổng số thẻ.
/// `mastered` = thẻ không đến hạn và không phải mới = đã ghi nhớ tốt.
class DeckProgress {
  final int due;
  final int fresh; // thẻ mới chưa từng ôn (tránh trùng từ khoá `new`)
  final int total;

  const DeckProgress({
    required this.due,
    required this.fresh,
    required this.total,
  });

  int get mastered => (total - due - fresh).clamp(0, total);

  /// Tỉ lệ đã thuộc trên tổng (0..1). Trả 0 khi bộ rỗng.
  double get masteryRatio => total <= 0 ? 0 : mastered / total;

  bool get hasDue => due > 0;
}
