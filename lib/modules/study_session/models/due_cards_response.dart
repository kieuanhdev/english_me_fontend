import 'package:englishme/modules/flashcard/models/flashcard_model.dart';

/// Response từ `GET /api/study-sessions/due-cards`.
/// Tách 2 nhóm: thẻ đã đến hạn ôn (SM-2 nextReviewAt <= now) + thẻ mới chưa thấy.
class DueCardsResponse {
  final List<FlashcardModel> dueCards;
  final List<FlashcardModel> newCards;
  final int totalDue;
  final int totalNew;

  const DueCardsResponse({
    required this.dueCards,
    required this.newCards,
    required this.totalDue,
    required this.totalNew,
  });

  factory DueCardsResponse.fromJson(Map<String, dynamic> json) {
    final due = json['dueCards'];
    final fresh = json['newCards'];
    return DueCardsResponse(
      dueCards: due is List
          ? due
                .whereType<Map<String, dynamic>>()
                .map(FlashcardModel.fromJson)
                .toList()
          : const [],
      newCards: fresh is List
          ? fresh
                .whereType<Map<String, dynamic>>()
                .map(FlashcardModel.fromJson)
                .toList()
          : const [],
      totalDue: (json['totalDue'] as num?)?.toInt() ?? 0,
      totalNew: (json['totalNew'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Session trả về sau `POST /api/study-sessions/start`.
class StudySessionStartResponse {
  final String sessionId;
  final String deskId;
  final List<FlashcardModel> cards;
  final int totalCards;

  const StudySessionStartResponse({
    required this.sessionId,
    required this.deskId,
    required this.cards,
    required this.totalCards,
  });

  factory StudySessionStartResponse.fromJson(Map<String, dynamic> json) {
    final cardsRaw = json['cards'];
    final cards = cardsRaw is List
        ? cardsRaw
              .whereType<Map<String, dynamic>>()
              .map(FlashcardModel.fromJson)
              .toList()
        : <FlashcardModel>[];
    return StudySessionStartResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      deskId: (json['deskId'] ?? '').toString(),
      cards: cards,
      totalCards: (json['totalCards'] as num?)?.toInt() ?? cards.length,
    );
  }
}
