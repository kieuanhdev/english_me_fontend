import 'package:get/get.dart';
import 'package:englishme/routes/app_routes.dart';

enum DeckLevel { advanced, intermediate, essential }

class FlashcardDeck {
  final String id;
  final String title;
  final int cardCount;
  final String category;
  final DeckLevel level;
  final double mastery;
  final String iconName;
  final int iconBgColorHex;
  final int iconColorHex;

  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.cardCount,
    required this.category,
    required this.level,
    required this.mastery,
    required this.iconName,
    required this.iconBgColorHex,
    required this.iconColorHex,
  });

  String get levelLabel => switch (level) {
    DeckLevel.advanced => 'ADVANCED',
    DeckLevel.intermediate => 'INTERMEDIATE',
    DeckLevel.essential => 'ESSENTIAL',
  };
}

class FlashcardController extends GetxController {
  // Word of the day
  final RxString wordOfDay = 'Eloquent'.obs;
  final RxString wordDefinition = 'Fluent or persuasive in speaking or writing.'.obs;

  // Stats
  final RxInt dayStreak = 12.obs;
  final RxInt avgMastery = 85.obs;

  // Decks
  final RxList<FlashcardDeck> decks = <FlashcardDeck>[
    const FlashcardDeck(
      id: '1',
      title: 'IELTS Academic',
      cardCount: 120,
      category: 'Vocabulary',
      level: DeckLevel.advanced,
      mastery: 0.68,
      iconName: 'school',
      iconBgColorHex: 0xFFDEE0FF,
      iconColorHex: 0xFF24389C,
    ),
    const FlashcardDeck(
      id: '2',
      title: 'Daily Expressions',
      cardCount: 45,
      category: 'Phrases',
      level: DeckLevel.essential,
      mastery: 0.92,
      iconName: 'chat_bubble',
      iconBgColorHex: 0xFFC9CFFD,
      iconColorHex: 0xFF565C84,
    ),
    const FlashcardDeck(
      id: '3',
      title: 'Business English',
      cardCount: 82,
      category: 'Meetings',
      level: DeckLevel.intermediate,
      mastery: 0.34,
      iconName: 'work',
      iconBgColorHex: 0xFFFFDCBE,
      iconColorHex: 0xFF643900,
    ),
  ].obs;

  void onPracticeWordOfDay() {
    // TODO: navigate to word detail / study session
  }

  void onStartStudy(FlashcardDeck deck) {
    Get.toNamed(AppRoutes.studySession);
  }

  void onCreateDeck() {
    // TODO: open create deck dialog / screen
  }

  void onViewAll() {
    // TODO: navigate to full deck list
  }
}
