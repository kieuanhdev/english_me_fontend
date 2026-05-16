import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/routes/app_routes.dart';

class HomeController extends GetxController {
  // User info
  final RxString userName = 'Kiều Anh'.obs;
  final RxString userLevel = 'A2'.obs;
  final RxString greetingLabel = 'Chào buổi sáng'.obs;

  // Daily XP progress
  final RxInt currentXp = 35.obs;
  final RxInt targetXp = 50.obs;

  double get xpProgress => targetXp.value > 0 ? currentXp.value / targetXp.value : 0;

  // Daily streak
  final RxInt streakDays = 7.obs;

  // Quick stats
  final RxInt xpToday = 35.obs;
  final RxInt cardsLearned = 12.obs;
  final RxInt exerciseDone = 3.obs;

  // Word of the day saved state
  final RxBool wordSaved = false.obs;

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
      title: 'Luyện từ vựng',
      subtitle: 'Chủ đề Du lịch & Công việc',
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
      title: 'Phát âm /θ/ và /ð/',
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

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingLabel.value = 'Chào buổi sáng';
    } else if (hour < 18) {
      greetingLabel.value = 'Chào buổi chiều';
    } else {
      greetingLabel.value = 'Chào buổi tối';
    }
  }

  void onListenWordOfDay() {
    // TODO: integrate TTS audio playback
  }

  void onAddWordToFlashcard() {
    wordSaved.value = !wordSaved.value;
    Get.snackbar(
      wordSaved.value ? 'Đã lưu' : 'Đã bỏ lưu',
      wordSaved.value
          ? '"${wordOfDay.value}" đã thêm vào Flashcard'
          : '"${wordOfDay.value}" đã xóa khỏi Flashcard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }

  void onSeeAllLessons() {
    Get.toNamed(AppRoutes.vocabulary);
  }

  void onContinueLearning() {
    Get.toNamed(AppRoutes.vocabularyList, arguments: {
      'topicId': 'travel',
      'topicTitle': 'Travel Vocabulary',
    });
  }

  void onRecommendTap(RecommendItem item) {
    switch (item.icon) {
      case 'psychology':
        Get.toNamed(AppRoutes.vocabulary);
      case 'quiz':
        Get.toNamed(AppRoutes.exercise);
      case 'mic':
        Get.toNamed(AppRoutes.pronunciation);
      case 'smart_toy':
        Get.toNamed(AppRoutes.chatAi);
    }
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
