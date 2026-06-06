/// Thông báo in-app (polling). Tên `AppNotification` để tránh trùng
/// `Notification` của Flutter material.
class AppNotification {
  final String id;
  final String type; // REVIEW_DUE | STREAK_RISK | LESSON_UNLOCKED | PLACEMENT_SUGGESTION | SYSTEM
  final String title;
  final String body;
  final String? actionRoute;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actionRoute,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'SYSTEM',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actionRoute: json['actionRoute'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        actionRoute: actionRoute,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
