import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/modules/vocabulary/models/vocabulary_model.dart';
import 'package:englishme/modules/vocabulary/repositories/vocabulary_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum VocabScreenState { idle, loading, loaded, error }

class VocabularyController extends GetxController {
  final VocabularyRepository _repo;

  VocabularyController(this._repo);

  // ── Topics ──────────────────────────────────────────────────────────────────
  final topicsState = VocabScreenState.idle.obs;
  final topics = <VocabularyTopic>[].obs;

  // ── Word list ────────────────────────────────────────────────────────────────
  final wordsState = VocabScreenState.idle.obs;
  final words = <VocabularyWord>[].obs;
  final currentTopic = Rxn<VocabularyTopic>();
  final flippedCards = <String>{}.obs;
  final savedWords = <String>{}.obs;

  // ── Spelling practice ────────────────────────────────────────────────────────
  final spellingWords = <VocabularyWord>[].obs;
  final spellingIndex = 0.obs;
  final spellingInput = ''.obs;
  final spellingState = SpellingState.idle.obs;
  final spellingResults = <SpellingResult>[].obs;
  final spellingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTopics();
  }

  @override
  void onClose() {
    spellingController.dispose();
    super.onClose();
  }

  // ── Topic loading ─────────────────────────────────────────────────────────────
  Future<void> loadTopics() async {
    topicsState.value = VocabScreenState.loading;
    try {
      final result = await _repo.getTopics();
      topics.assignAll(result);
      topicsState.value = VocabScreenState.loaded;
    } catch (_) {
      topicsState.value = VocabScreenState.error;
    }
  }

  // ── Word list ─────────────────────────────────────────────────────────────────
  Future<void> openTopic(VocabularyTopic topic) async {
    currentTopic.value = topic;
    flippedCards.clear();
    wordsState.value = VocabScreenState.loading;
    Get.toNamed(AppRoutes.vocabularyList);
    try {
      final result = await _repo.getWordsByTopic(topic.id);
      words.assignAll(result);
      wordsState.value = VocabScreenState.loaded;
    } catch (_) {
      wordsState.value = VocabScreenState.error;
    }
  }

  void toggleCard(String wordId) {
    if (flippedCards.contains(wordId)) {
      flippedCards.remove(wordId);
    } else {
      flippedCards.add(wordId);
    }
  }

  bool isFlipped(String wordId) => flippedCards.contains(wordId);

  void toggleSave(String wordId) {
    if (savedWords.contains(wordId)) {
      savedWords.remove(wordId);
    } else {
      savedWords.add(wordId);
    }
  }

  bool isSaved(String wordId) => savedWords.contains(wordId);

  // ── Spelling practice ─────────────────────────────────────────────────────────
  void startSpelling() {
    spellingWords.assignAll(List.of(words)..shuffle());
    spellingIndex.value = 0;
    spellingInput.value = '';
    spellingResults.clear();
    spellingState.value = SpellingState.typing;
    spellingController.clear();
    Get.toNamed(AppRoutes.spellingPractice);
  }

  void onSpellingInputChange(String value) {
    spellingInput.value = value;
  }

  void submitSpelling() {
    if (spellingState.value != SpellingState.typing) return;
    final word = currentSpellingWord;
    if (word == null) return;

    final input = spellingInput.value.trim();
    final correct = input.toLowerCase() == word.word.toLowerCase();
    spellingState.value = correct ? SpellingState.correct : SpellingState.wrong;
    spellingResults.add(SpellingResult(
      wordId: word.id,
      word: word.word,
      userInput: input,
      isCorrect: correct,
    ));
  }

  void nextSpellingWord() {
    if (spellingIndex.value >= spellingWords.length - 1) {
      Get.offNamed(AppRoutes.spellingResult);
      return;
    }
    spellingIndex.value++;
    spellingInput.value = '';
    spellingState.value = SpellingState.typing;
    spellingController.clear();
  }

  VocabularyWord? get currentSpellingWord {
    if (spellingWords.isEmpty || spellingIndex.value >= spellingWords.length) return null;
    return spellingWords[spellingIndex.value];
  }

  int get spellingCorrectCount => spellingResults.where((r) => r.isCorrect).length;

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String levelLabel(VocabularyLevel level) {
    switch (level) {
      case VocabularyLevel.a1: return 'A1';
      case VocabularyLevel.a2: return 'A2';
      case VocabularyLevel.b1: return 'B1';
      case VocabularyLevel.b2: return 'B2';
      case VocabularyLevel.c1: return 'C1';
      case VocabularyLevel.c2: return 'C2';
    }
  }

  Color levelColor(VocabularyLevel level) {
    switch (level) {
      case VocabularyLevel.a1: return const Color(0xFF4CAF50);
      case VocabularyLevel.a2: return const Color(0xFF8BC34A);
      case VocabularyLevel.b1: return const Color(0xFF2196F3);
      case VocabularyLevel.b2: return const Color(0xFF9C27B0);
      case VocabularyLevel.c1: return const Color(0xFFFF9800);
      case VocabularyLevel.c2: return const Color(0xFFF44336);
    }
  }
}
