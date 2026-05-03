import 'package:get/get.dart';
import 'package:englishme/modules/study_session/views/session_summary_screen.dart';
import 'package:englishme/modules/study_session/views/study_session_back_screen.dart';

enum CardRating { forget, vague, remember, mastered }

class StudyCard {
  final String id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaning;
  final String vietnameseMeaning;
  final String exampleEn;
  final String exampleVi;
  final String scholarTip;

  const StudyCard({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaning,
    required this.vietnameseMeaning,
    required this.exampleEn,
    required this.exampleVi,
    required this.scholarTip,
  });
}

class StudySessionController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final RxInt masteredCount = 0.obs;
  final RxInt rememberCount = 0.obs;
  final RxInt vagueCount = 0.obs;
  final RxInt forgetCount = 0.obs;

  final RxInt streakDays = 7.obs;
  final RxInt xpEarned = 25.obs;
  final RxInt currentLevel = 12.obs;
  final RxDouble xpProgress = 0.75.obs;

  final List<StudyCard> cards = const [
    StudyCard(
      id: '1',
      word: 'Ethereal',
      phonetic: '/iˈθɪə.ri.əl/',
      partOfSpeech: 'adjective',
      meaning: 'Extremely delicate and light, seemingly not of this world.',
      vietnameseMeaning: 'Thanh tao, siêu trần',
      exampleEn: 'Her ethereal beauty captivated everyone.',
      exampleVi: 'Vẻ đẹp thanh tao của cô ấy đã mê hoặc tất cả mọi người.',
      scholarTip: 'Words ending in -al are often adjectives. Imagine something light, airy, and celestial.',
    ),
    StudyCard(
      id: '2',
      word: 'Eloquent',
      phonetic: '/ˈel.ə.kwənt/',
      partOfSpeech: 'adjective',
      meaning: 'Fluent or persuasive in speaking or writing.',
      vietnameseMeaning: 'Hùng hồn, lưu loát',
      exampleEn: 'He gave an eloquent speech at the ceremony.',
      exampleVi: 'Anh ấy đã phát biểu hùng hồn tại buổi lễ.',
      scholarTip: 'From Latin "eloqui" meaning to speak out. Think of a great orator.',
    ),
    StudyCard(
      id: '3',
      word: 'Resilient',
      phonetic: '/rɪˈzɪl.i.ənt/',
      partOfSpeech: 'adjective',
      meaning: 'Able to withstand or recover quickly from difficult conditions.',
      vietnameseMeaning: 'Kiên cường, phục hồi nhanh',
      exampleEn: 'Children are remarkably resilient in tough times.',
      exampleVi: 'Trẻ em rất kiên cường trong những lúc khó khăn.',
      scholarTip: 'From Latin "resilire" — to spring back. Like a rubber band.',
    ),
  ];

  StudyCard get currentCard => cards[currentIndex.value];
  int get totalCards => cards.length;
  int get totalReviewed => masteredCount.value + rememberCount.value + vagueCount.value + forgetCount.value;

  void flipCard() => Get.to(() => const StudySessionBackScreen(), preventDuplicates: false);

  void rateCard(CardRating rating) {
    switch (rating) {
      case CardRating.mastered:
        masteredCount.value++;
      case CardRating.remember:
        rememberCount.value++;
      case CardRating.vague:
        vagueCount.value++;
      case CardRating.forget:
        forgetCount.value++;
    }

    if (currentIndex.value < cards.length - 1) {
      currentIndex.value++;
      Get.back(); // go back to front screen for next card
    } else {
      Get.off(() => const SessionSummaryScreen());
    }
  }

  void closeSession() => Get.until((route) => route.settings.name == '/flashcards' || route.isFirst);
}
