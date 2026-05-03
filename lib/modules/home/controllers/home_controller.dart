import 'package:get/get.dart';

class HomeController extends GetxController {
  // User info
  final RxString userName = 'Kiều Anh'.obs;
  final RxString userLevel = 'A2'.obs;
  final RxString greetingLabel = 'Chào buổi sáng'.obs;

  // Daily XP progress
  final RxInt currentXp = 35.obs;
  final RxInt targetXp = 50.obs;

  double get xpProgress => targetXp.value > 0 ? currentXp.value / targetXp.value : 0;

  // Continue learning card
  final RxString lessonLevel = 'CẤP ĐỘ A2'.obs;
  final RxString lessonTitle = 'Travel Vocabulary'.obs;
  final RxInt lessonCurrent = 4.obs;
  final RxInt lessonTotal = 12.obs;
  final RxDouble lessonProgress = 0.45.obs;

  // Word of the day
  final RxString wordOfDay = 'Ethereal'.obs;
  final RxString wordIpa = '/ɪˈθɪə.ri.əl/'.obs;
  final RxString wordDefinitionEn = 'Extremely light and beautiful; not of this world.'.obs;
  final RxString wordDefinitionVi = 'Thanh tao, siêu trần, không thuộc về cõi trần này.'.obs;

  // Recommendations
  final RxList<RecommendItem> recommendations = <RecommendItem>[
    RecommendItem(
      icon: 'psychology',
      title: 'Luyện nghe hội thoại',
      subtitle: 'Hội thoại thực tế tại sân bay',
      isWide: true,
      isOrange: false,
    ),
    RecommendItem(
      icon: 'quiz',
      title: 'Mini Quiz: Quá khứ đơn',
      subtitle: '',
      isWide: false,
      isOrange: false,
    ),
    RecommendItem(
      icon: 'mic',
      title: 'Phát âm âm /θ/ và /ð/',
      subtitle: '',
      isWide: false,
      isOrange: true,
    ),
    RecommendItem(
      icon: 'smart_toy',
      title: 'Chat AI luyện tập',
      subtitle: 'Phỏng vấn xin việc cơ bản',
      isWide: true,
      isOrange: false,
    ),
  ].obs;

  void onListenWordOfDay() {
    // TODO: integrate audio playback
  }

  void onSeeAllLessons() {
    // TODO: navigate to lessons list
  }

  void onContinueLearning() {
    // TODO: navigate to current lesson
  }

  void onRecommendTap(RecommendItem item) {
    // TODO: navigate based on item type
  }
}

class RecommendItem {
  final String icon;
  final String title;
  final String subtitle;
  final bool isWide;
  final bool isOrange;

  RecommendItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isWide,
    required this.isOrange,
  });
}
