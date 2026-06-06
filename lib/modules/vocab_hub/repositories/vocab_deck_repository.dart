import 'package:dio/dio.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';

class VocabDeckRepository {
  final Dio _dio;
  VocabDeckRepository(this._dio);

  // NOTE: endpoint backend là `/desks` + param `deskId` — giữ nguyên theo API.
  Future<List<VocabDeck>> getDecks() async {
    final response = await _dio.get('/desks');
    return (response.data as List<dynamic>)
        .map((e) => VocabDeck.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VocabDeck> createDeck({
    String? cefrLevel,
    String? title,
    int? sortOrder,
  }) async {
    final response = await _dio.post(
      '/desks',
      data: {
        if (cefrLevel != null && cefrLevel.trim().isNotEmpty)
          'cefrLevel': cefrLevel,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );
    final parsed = _extractDeckJson(response.data);
    if (parsed != null) return VocabDeck.fromJson(_normalizeDeckJson(parsed));
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Dữ liệu bộ thẻ trả về không hợp lệ',
    );
  }

  Future<VocabDeck> updateDeck({
    required String deckId,
    String? cefrLevel,
    String? title,
    int? sortOrder,
  }) async {
    final response = await _dio.put(
      '/desks/$deckId',
      data: {
        if (cefrLevel != null) 'cefrLevel': cefrLevel,
        if (title != null) 'title': title.trim(),
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );
    final parsed = _extractDeckJson(response.data);
    if (parsed != null) return VocabDeck.fromJson(_normalizeDeckJson(parsed));
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Dữ liệu bộ thẻ cập nhật không hợp lệ',
    );
  }

  Future<void> deleteDeck(String deckId) => _dio.delete('/desks/$deckId');

  Future<VocabWordPage> getFlashcards(String deckId, {int page = 0, int size = 20}) async {
    final response = await _dio.get(
      '/desks/$deckId/flashcards',
      queryParameters: {'page': page, 'size': size},
    );
    return VocabWordPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createFlashcard({
    required String deckId,
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) =>
      _dio.post('/desks/$deckId/flashcards', data: _payload(word, ipa, pos, vietnamese, example, cefr));

  Future<void> updateFlashcard({
    required String deckId,
    required String flashcardId,
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) =>
      _dio.put('/desks/$deckId/flashcards/$flashcardId',
          data: _payload(word, ipa, pos, vietnamese, example, cefr));

  Map<String, dynamic> _payload(
    String word,
    String ipa,
    List<String> pos,
    String vietnamese,
    String example,
    String cefr,
  ) =>
      {
        'word': word,
        'ipa': ipa,
        'pos': pos,
        'definition': '',
        'example': example,
        'topic': 'Custom',
        'cefr': cefr,
        'vietnamese': vietnamese,
        'viDefinition': vietnamese,
        'viExample': '',
      };

  Map<String, dynamic>? _extractDeckJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (_looksLikeDeck(data)) return data;
      final nested = data['data'];
      if (nested is Map<String, dynamic> && _looksLikeDeck(nested)) return nested;
    }
    return null;
  }

  bool _looksLikeDeck(Map<String, dynamic> json) =>
      json['id'] != null && json['title'] != null && json['cefrLevel'] != null;

  Map<String, dynamic> _normalizeDeckJson(Map<String, dynamic> json) => {
        'id': json['id'],
        'title': json['title'],
        'cefrLevel': json['cefrLevel'],
        'sortOrder': (json['sortOrder'] as num?)?.toInt() ?? 0,
        'createdAt': (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
        'flashcardCount': (json['flashcardCount'] as num?)?.toInt() ?? 0,
      };
}
