import 'package:dio/dio.dart';
import 'package:englishme/modules/flashcard/models/desk_model.dart';
import 'package:englishme/modules/flashcard/models/flashcard_model.dart';

class FlashcardRepository {
  final Dio _dio;

  FlashcardRepository(this._dio);

  Future<List<DeskModel>> getDesks() async {
    final response = await _dio.get('/desks');
    return (response.data as List<dynamic>)
        .map((e) => DeskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeskModel> createDesk({
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
    if (parsed != null) return DeskModel.fromJson(_normalizeDeskJson(parsed));
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Dữ liệu bộ thẻ trả về không hợp lệ',
    );
  }

  Future<DeskModel> updateDesk({
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
    if (parsed != null) return DeskModel.fromJson(_normalizeDeskJson(parsed));
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Dữ liệu bộ thẻ cập nhật không hợp lệ',
    );
  }

  Future<void> deleteDesk(String deskId) async {
    await _dio.delete('/desks/$deskId');
  }

  Future<FlashcardPage> getFlashcards(
    String deskId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/desks/$deskId/flashcards',
      queryParameters: {'page': page, 'size': size},
    );
    return FlashcardPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createFlashcard({
    required String deskId,
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) async {
    await _dio.post(
      '/desks/$deskId/flashcards',
      data: _flashcardPayload(
        word: word,
        ipa: ipa,
        pos: pos,
        vietnamese: vietnamese,
        example: example,
        cefr: cefr,
      ),
    );
  }

  Future<void> updateFlashcard({
    required String deskId,
    required String flashcardId,
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) async {
    await _dio.put(
      '/desks/$deskId/flashcards/$flashcardId',
      data: _flashcardPayload(
        word: word,
        ipa: ipa,
        pos: pos,
        vietnamese: vietnamese,
        example: example,
        cefr: cefr,
      ),
    );
  }

  Map<String, dynamic> _flashcardPayload({
    required String word,
    required String ipa,
    required List<String> pos,
    required String vietnamese,
    required String example,
    required String cefr,
  }) {
    return {
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
  }

  Map<String, dynamic>? _extractDeskJson(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (_looksLikeDesk(responseData)) return responseData;
      final nested = responseData['data'];
      if (nested is Map<String, dynamic> && _looksLikeDesk(nested)) return nested;
    }
    return null;
  }

  bool _looksLikeDesk(Map<String, dynamic> json) =>
      json['id'] != null && json['title'] != null && json['cefrLevel'] != null;

  Map<String, dynamic> _normalizeDeskJson(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'title': json['title'],
      'cefrLevel': json['cefrLevel'],
      'sortOrder': (json['sortOrder'] as num?)?.toInt() ?? 0,
      'createdAt': (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      'flashcardCount': (json['flashcardCount'] as num?)?.toInt() ?? 0,
    };
  }
}
