import 'package:firebase_auth/firebase_auth.dart';
import 'package:englishme/modules/profile/models/profile_model.dart';

class ProfileRepository {
  final FirebaseAuth _auth;

  ProfileRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<ProfileUser> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return ProfileUser(
      uid: user.uid,
      displayName: user.displayName ?? 'Học viên',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      cefrLevel: 'B1',
      totalXp: 1240,
      currentStreak: 7,
      longestStreak: 15,
      joinedAt: user.metadata.creationTime,
      badges: _defaultBadges(),
    );
  }

  Future<void> updateDisplayName(String uid, String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  List<Badge> _defaultBadges() => [
        const Badge(
          id: 'first_login',
          title: 'Bước đầu tiên',
          description: 'Đăng nhập lần đầu',
          icon: '🎯',
          unlocked: true,
        ),
        const Badge(
          id: 'streak_7',
          title: '7 ngày liên tiếp',
          description: 'Học 7 ngày không nghỉ',
          icon: '🔥',
          unlocked: true,
        ),
        const Badge(
          id: 'flashcard_100',
          title: 'Nhà flashcard',
          description: 'Học 100 thẻ flashcard',
          icon: '📚',
          unlocked: true,
        ),
        const Badge(
          id: 'streak_30',
          title: '30 ngày liên tiếp',
          description: 'Học 30 ngày không nghỉ',
          icon: '💎',
          unlocked: false,
        ),
        const Badge(
          id: 'pronunciation_master',
          title: 'Phát âm chuẩn',
          description: 'Đạt 90+ điểm phát âm',
          icon: '🎤',
          unlocked: false,
        ),
        const Badge(
          id: 'grammar_ace',
          title: 'Ngữ pháp vững',
          description: 'Hoàn thành toàn bộ Grammar',
          icon: '📝',
          unlocked: false,
        ),
      ];
}
