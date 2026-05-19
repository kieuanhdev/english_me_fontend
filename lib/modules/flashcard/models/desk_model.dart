class DeskModel {
  final String id;
  final String cefrLevel;
  final String title;
  final int sortOrder;
  final String createdAt;
  final int flashcardCount;

  const DeskModel({
    required this.id,
    required this.cefrLevel,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.flashcardCount,
  });

  factory DeskModel.fromJson(Map<String, dynamic> json) => DeskModel(
        id: json['id'] as String,
        cefrLevel: json['cefrLevel'] as String,
        title: json['title'] as String,
        sortOrder: json['sortOrder'] as int,
        createdAt: json['createdAt'] as String,
        flashcardCount: json['flashcardCount'] as int,
      );
}
