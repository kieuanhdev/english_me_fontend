/// Response từ `GET /api/users/me` (mục 11.2 PROJECT_DOCUMENTATION).
class UserProfileResponse {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? cefrLevel;
  final bool isOnboarded;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime? createdAt;
  final List<BadgeDto> badges;

  const UserProfileResponse({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.cefrLevel,
    required this.isOnboarded,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    this.createdAt,
    required this.badges,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final badgesRaw = json['badges'];
    return UserProfileResponse(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      cefrLevel: json['cefrLevel'] as String?,
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: _parseDate(json['lastActiveDate']),
      createdAt: _parseDate(json['createdAt']),
      badges: badgesRaw is List
          ? badgesRaw
                .whereType<Map<String, dynamic>>()
                .map(BadgeDto.fromJson)
                .toList()
          : const [],
    );
  }
}

class BadgeDto {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? conditionType;
  final DateTime? earnedAt;

  const BadgeDto({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.conditionType,
    this.earnedAt,
  });

  factory BadgeDto.fromJson(Map<String, dynamic> json) => BadgeDto(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    description: json['description'] as String?,
    iconUrl: json['iconUrl'] as String?,
    conditionType: json['conditionType'] as String?,
    earnedAt: _parseDate(json['earnedAt']),
  );
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}
