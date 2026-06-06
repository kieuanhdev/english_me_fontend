import 'package:dio/dio.dart';

import 'package:englishme/modules/notification/models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  Future<List<AppNotification>> list({bool unreadOnly = false, int limit = 30}) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {'unreadOnly': unreadOnly, 'limit': limit},
    );
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  Future<int> unreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> markRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }
}
