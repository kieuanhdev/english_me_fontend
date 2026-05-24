class ProfileUser {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String cefrLevel;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final List<Badge> badges;
  final DateTime? joinedAt;

  const ProfileUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.cefrLevel,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
    this.joinedAt,
  });

  ProfileUser copyWith({
    String? displayName,
    String? photoUrl,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
  }) {
    return ProfileUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      cefrLevel: cefrLevel,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      badges: badges,
      joinedAt: joinedAt,
    );
  }
}

class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });
}
