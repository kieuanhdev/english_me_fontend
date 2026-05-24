import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:englishme/core/config/app_config.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/home/models/home_dashboard_model.dart';
import 'package:englishme/modules/home/repositories/home_repository.dart';
import 'package:englishme/modules/learn/controllers/learning_controller.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/routes/app_routes.dart';

enum HomeLoadState { idle, loading, success, error }
enum WordOfDayState { idle, loading, loaded, empty, error }

class HomeController extends GetxController {
  final HomeRepository _repo;
  HomeController(this._repo);

  final AudioPlayer _wordAudioPlayer = AudioPlayer();

  final loadState = HomeLoadState.idle.obs;
  final Rxn<HomeDashboardResponse> dashboard = Rxn();
  final Rxn<WordOfDayDto> dailyWord = Rxn();
  final RxString greetingLabel = T.homeGreeting.tr.obs;
  final RxBool wordSaved = false.obs;
  final wordOfDayState = WordOfDayState.idle.obs;
  final wordOfDayMessage = ''.obs;

  static const int dailyXpTarget = 50;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
    loadDashboard();
    loadWordOfDay();
  }

  @override
  void onClose() {
    _wordAudioPlayer.dispose();
    super.onClose();
  }

  Future<void> loadDashboard() async {
    try {
      loadState.value = HomeLoadState.loading;
      dashboard.value = await _repo.getDashboard();
      loadState.value = HomeLoadState.success;
    } catch (_) {
      loadState.value = HomeLoadState.error;
    }
  }

  Future<void> reloadDashboard() async {
    await Future.wait([
      loadDashboard(),
      loadWordOfDay(forceRefresh: true),
    ]);
  }

  Future<void> loadWordOfDay({bool forceRefresh = false}) async {
    try {
      wordOfDayState.value = WordOfDayState.loading;
      wordOfDayMessage.value = '';
      final result = await _repo.getWordOfDay(forceRefresh: forceRefresh);
      dailyWord.value = result;
      wordSaved.value = false;
      wordOfDayState.value =
          result == null ? WordOfDayState.empty : WordOfDayState.loaded;
      if (result == null) {
        wordOfDayMessage.value =
            'Làm placement test để nhận từ vựng mỗi ngày theo level của bạn.';
      }
    } catch (_) {
      wordOfDayState.value = WordOfDayState.error;
      wordOfDayMessage.value =
          'Không tải được từ vựng mỗi ngày. Vui lòng thử lại.';
    }
  }

  // ----- User -----
  String get userName {
    final name = dashboard.value?.user.fullName;
    return (name != null && name.isNotEmpty) ? name : T.homeDefaultName.tr;
  }

  String get userLevel => dashboard.value?.user.cefrLevel ?? '—';

  // ----- Daily XP -----
  int get currentXp => dashboard.value?.dailyStats.xpToday ?? 0;
  int get targetXp => dailyXpTarget;
  double get xpProgress => targetXp > 0 ? (currentXp / targetXp).clamp(0.0, 1.0) : 0.0;

  // ----- Quick stats -----
  int get streakDays => dashboard.value?.dailyStats.currentStreak ?? 0;
  int get xpToday => dashboard.value?.dailyStats.xpToday ?? 0;
  int get xpWeek => dashboard.value?.dailyStats.xpWeek ?? 0;
  int get activeDaysThisWeek => dashboard.value?.dailyStats.activeDaysThisWeek ?? 0;

  // ----- Continue learning -----
  ContinueLearning? get continueLearning => dashboard.value?.continueLearning;

  LearningPath? get currentLearningPath {
    if (!Get.isRegistered<LearningController>()) return null;
    final learningHub = Get.find<LearningController>().hub.value;
    if (learningHub == null || learningHub.paths.isEmpty) return null;

    final currentPathId = learningHub.currentPathId;
    if (currentPathId != null && currentPathId.trim().isNotEmpty) {
      final matching = learningHub.paths.where((path) => path.id == currentPathId);
      if (matching.isNotEmpty) return matching.first;
    }

    final inProgress = learningHub.paths.where(
      (path) => path.status == 'in_progress' || path.progress > 0,
    );
    if (inProgress.isNotEmpty) return inProgress.first;

    final available = learningHub.paths.where((path) => !path.isLocked);
    return available.isNotEmpty ? available.first : learningHub.paths.first;
  }

  // ----- Word of day -----
  WordOfDayDto? get wordOfDay => dailyWord.value;

  // ----- Recommendations -----
  List<HomeRecommendation> get recommendations =>
      dashboard.value?.recommendations ?? const [];

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingLabel.value = T.homeGreetingMorning.tr;
    } else if (hour < 18) {
      greetingLabel.value = T.homeGreetingAfternoon.tr;
    } else {
      greetingLabel.value = T.homeGreetingEvening.tr;
    }
  }

  Future<void> onListenWordOfDay() async {
    final audioUrl = _resolveAudioUrl(wordOfDay?.audioUrl);
    if (audioUrl != null) {
      try {
        await _wordAudioPlayer.stop();
        await _wordAudioPlayer.play(UrlSource(audioUrl));
        return;
      } catch (_) {
        // Fall back to TTS when the audio file is unavailable.
      }
    }
    final word = wordOfDay?.word;
    if (word == null || word.trim().isEmpty) return;
    await Get.find<TtsService>().speak(word);
  }

  String? _resolveAudioUrl(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final path = value.replaceFirst(RegExp(r'^/+'), '');
    return '$base/$path';
  }

  void onAddWordToFlashcard() {
    final word = wordOfDay?.word;
    if (word == null) return;
    wordSaved.value = !wordSaved.value;
    Get.snackbar(
      wordSaved.value ? T.homeWordSaved.tr : T.homeWordUnsaved.tr,
      wordSaved.value
          ? T.homeWordAddedMsg.trParams({'word': word})
          : T.homeWordRemovedMsg.trParams({'word': word}),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }

  void onSeeAllLessons() {
    Get.toNamed(AppRoutes.learn);
  }

  void onStartPlacementTest() {
    Get.toNamed(AppRoutes.placementTest);
  }

  void onContinueLearning() {
    final path = currentLearningPath;
    if (path != null) {
      Get.toNamed(
        AppRoutes.learningPathDetail,
        arguments: {'level': path.level, 'pathId': path.id},
      );
      return;
    }

    final cl = continueLearning;
    if (cl == null) {
      Get.toNamed(AppRoutes.learn);
      return;
    }
    if (cl.pathId != null && cl.pathId!.trim().isNotEmpty) {
      Get.toNamed(
        AppRoutes.learningPathDetail,
        arguments: {'level': cl.level ?? userLevel, 'pathId': cl.pathId},
      );
      return;
    }
    if (cl.type == 'vocabulary' && cl.topicId != null) {
      Get.toNamed(
        AppRoutes.vocabularyList,
        arguments: {'topicId': cl.topicId, 'topicTitle': cl.title ?? ''},
      );
      return;
    }
    Get.toNamed(AppRoutes.vocabulary);
  }

  void onRecommendTap(HomeRecommendation item) {
    switch (item.type) {
      case 'vocabulary':
        Get.toNamed(AppRoutes.vocabulary);
      case 'grammar':
        Get.toNamed(AppRoutes.grammar);
      case 'exercise':
        Get.toNamed(AppRoutes.learningSupport);
      case 'pronunciation':
        Get.toNamed(AppRoutes.pronunciation);
      case 'flashcard':
        Get.toNamed(AppRoutes.flashcards);
      case 'test':
        Get.toNamed(AppRoutes.learningSupport);
    }
  }
}
