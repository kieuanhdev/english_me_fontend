import 'package:dio/dio.dart';

import 'package:englishme/modules/study_session/models/due_cards_response.dart';
import 'package:englishme/modules/study_session/models/review_response.dart';
import 'package:englishme/modules/study_session/models/study_session_summary.dart';

class StudySessionRepository {
  final Dio _dio;
  StudySessionRepository(this._dio);

  Future<DueCardsResponse> getDueCards(String deskId, {int limit = 20}) async {
    final response = await _dio.get(
      '/study-sessions/due-cards',
      queryParameters: {'deskId': deskId, 'limit': limit},
    );
    return DueCardsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StudySessionStartResponse> startSession(
    String deskId, {
    int limit = 20,
  }) async {
    final response = await _dio.post(
      '/study-sessions/start',
      data: {'deskId': deskId, 'limit': limit},
    );
    return StudySessionStartResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ReviewResponse> reviewCard(
    String sessionId,
    ReviewRequest request,
  ) async {
    final response = await _dio.post(
      '/study-sessions/$sessionId/review',
      data: request.toJson(),
    );
    return ReviewResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StudySessionSummary> getSummary(String sessionId) async {
    final response = await _dio.get('/study-sessions/$sessionId/summary');
    return StudySessionSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
