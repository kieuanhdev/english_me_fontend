import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/home/models/home_dashboard_model.dart';
import 'package:englishme/modules/home/repositories/home_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum HomeLoadState { idle, loading, success, error }

class HomeController extends GetxController {
  final HomeRepository _repo;
  HomeController(this._repo);

  final loadState = HomeLoadState.idle.obs;
  final Rxn<HomeDashboardResponse> dashboard = Rxn();
  final RxString greetingLabel = T.homeGreeting.tr.obs;
  final RxBool wordSaved = false.obs;

  static const int dailyXpTarget = 50;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
    loadDashboard();
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

  Future<void> reloadDashboard() => loadDashboard();

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

  // ----- Word of day -----
  WordOfDayDto? get wordOfDay => dashboard.value?.wordOfDay;

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

  void onListenWordOfDay() {
    // TODO: integrate TTS audio playback for wordOfDay?.word
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
    Get.toNamed(AppRoutes.vocabulary);
  }

  void onContinueLearning() {
    final cl = continueLearning;
    if (cl == null) {
      Get.toNamed(AppRoutes.vocabulary);
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
        Get.toNamed(AppRoutes.exercise);
      case 'pronunciation':
        Get.toNamed(AppRoutes.pronunciation);
      case 'flashcard':
        Get.toNamed(AppRoutes.flashcards);
      case 'test':
        Get.toNamed(AppRoutes.test);
    }
  }
}
