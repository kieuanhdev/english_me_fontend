import 'package:firebase_auth/firebase_auth.dart';

import 'package:englishme/modules/auth/models/user_profile_model.dart';
import 'package:englishme/modules/auth/repositories/user_repository.dart';
import 'package:englishme/modules/profile/models/profile_model.dart';

class ProfileRepository {
  final UserRepository _userRepo;
  final FirebaseAuth _auth;

  ProfileRepository({
    required UserRepository userRepo,
    FirebaseAuth? auth,
  }) : _userRepo = userRepo,
       _auth = auth ?? FirebaseAuth.instance;

  Future<ProfileUser> getProfile() async {
    final dto = await _userRepo.getMe();
    return _toProfileUser(dto);
  }

  Future<ProfileUser> updateDisplayName(String name) async {
    final dto = await _userRepo.updateMe(displayName: name);
    return _toProfileUser(dto);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  ProfileUser _toProfileUser(UserProfileResponse dto) {
    return ProfileUser(
      uid: dto.id,
      displayName: dto.fullName?.isNotEmpty == true ? dto.fullName! : 'Học viên',
      email: dto.email,
      photoUrl: dto.avatarUrl,
      cefrLevel: dto.cefrLevel ?? '',
      totalXp: dto.totalXp,
      currentStreak: dto.currentStreak,
      longestStreak: dto.longestStreak,
      joinedAt: dto.createdAt,
      badges: dto.badges.map(_toBadge).toList(),
    );
  }

  Badge _toBadge(BadgeDto dto) => Badge(
    id: dto.id,
    title: dto.name,
    description: dto.description ?? '',
    icon: dto.iconUrl ?? '🏅',
    unlocked: dto.earnedAt != null,
    unlockedAt: dto.earnedAt,
  );
}
