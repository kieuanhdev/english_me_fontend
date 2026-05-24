import 'package:dio/dio.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_desk_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';

class VocabDeskRepository {
  final Dio _dio;
  VocabDeskRepository(this._dio);

  Future<List<VocabDesk>> getDesks() async {
    final response = await _dio.get('/desks');
    return (response.data as List<dynamic>)
        .map((e) => VocabDesk.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VocabDesk> createDesk({
    required String cefrLevel,
    String? title,
    int? sortOrder,
  }) async {
    final response = await _dio.post(
      '/desks',
      data: {
        'cefrLevel': cefrLevel,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );
    final parsed = _extractDeskJson(response.data);
    if (parsed != null) return VocabDesk.fromJson(_normalizeDeskJson(parsed));
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Dữ liệu bộ thẻ trả về không hợp lệ',
    );
  }

  Future<VocabDesk> updateDesk({
    required String deskId,
    String? cefrLevel,
    String? title,
    int? sortOrder,
  }) async {
    final response = await _dio.put(
      '/desks/$deskId',
      data: {
        if (cefrLevel != null) 'cefrLevel': cefrLevel,
        if (title != null) 'title': title.trim(),
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );
    final parsed = _extractDeskJson(response.data);
    if (parsed != null) return VocabDesk.fromJson(_normalizeDeskJson(parsed));
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Dữ liệu bộ thẻ cập nhật không hợp lệ',
    );
  }

  Future<void> deleteDesk(String deskId) => _dio.delete('/desks/$deskId');

  Future<VocabWordPage> getFlashcards(String deskId, {int page = 0, int size = 20}) async {
    final response = await _dio.get(
      '/desks/$deskId/flashcards',
      queryParameters: {'page': page, 'size': size},
    );
    return VocabWordPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createFlashcard({
    required String deskId,
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) =>
      _dio.post('/desks/$deskId/flashcards', data: _payload(word, ipa, pos, vietnamese, example, cefr));

  Future<void> updateFlashcard({
    required String deskId,
    required String flashcardId,
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) =>
      _dio.put('/desks/$deskId/flashcards/$flashcardId',
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

  Map<String, dynamic>? _extractDeskJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (_looksLikeDesk(data)) return data;
      final nested = data['data'];
      if (nested is Map<String, dynamic> && _looksLikeDesk(nested)) return nested;
    }
    return null;
  }

  bool _looksLikeDesk(Map<String, dynamic> json) =>
      json['id'] != null && json['title'] != null && json['cefrLevel'] != null;

  Map<String, dynamic> _normalizeDeskJson(Map<String, dynamic> json) => {
        'id': json['id'],
        'title': json['title'],
        'cefrLevel': json['cefrLevel'],
        'sortOrder': (json['sortOrder'] as num?)?.toInt() ?? 0,
        'createdAt': (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
        'flashcardCount': (json['flashcardCount'] as num?)?.toInt() ?? 0,
      };
}
