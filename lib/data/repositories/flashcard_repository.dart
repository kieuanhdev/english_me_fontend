import 'package:dio/dio.dart';
import 'package:englishme/data/models/desk_model.dart';
import 'package:englishme/data/models/flashcard_model.dart';

class FlashcardRepository {
  final Dio _dio;

  FlashcardRepository(this._dio);

  Future<List<DeskModel>> getDesks() async {
    final response = await _dio.get('/desks');
    return (response.data as List<dynamic>)
        .map((e) => DeskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FlashcardPage> getFlashcards(
    String deskId, {
    int page = 0,
    int size = 40,
  }) async {
    final response = await _dio.get(
      '/desks/$deskId/flashcards',
      queryParameters: {'page': page, 'size': size},
    );
    return FlashcardPage.fromJson(response.data as Map<String, dynamic>);
  }
}
