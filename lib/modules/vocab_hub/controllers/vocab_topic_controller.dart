import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_topic_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_topic_repository.dart';
import 'package:englishme/routes/app_routes.dart';

enum VocabLoadState { idle, loading, loaded, error }

class VocabTopicController extends GetxController {
  final VocabTopicRepository _repo;
  VocabTopicController(this._repo);

  // ── Topics ──────────────────────────────────────────────────────────────────
  final topicsState = VocabLoadState.idle.obs;
  final topics = <VocabTopic>[].obs;

  // ── Word list ────────────────────────────────────────────────────────────────
  final wordsState = VocabLoadState.idle.obs;
  final words = <VocabWord>[].obs;
  final currentTopic = Rxn<VocabTopic>();
  final flippedCards = <String>{}.obs;
  final savedWords = <String>{}.obs;

  // ── Spelling practice ────────────────────────────────────────────────────────
  final spellingWords = <VocabWord>[].obs;
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

  // ── Topics ────────────────────────────────────────────────────────────────────
  Future<void> loadTopics() async {
    topicsState.value = VocabLoadState.loading;
    try {
      topics.assignAll(await _repo.getTopics());
      topicsState.value = VocabLoadState.loaded;
    } catch (_) {
      topicsState.value = VocabLoadState.error;
    }
  }

  // ── Word list ─────────────────────────────────────────────────────────────────
  Future<void> openTopic(VocabTopic topic) async {
    currentTopic.value = topic;
    flippedCards.clear();
    wordsState.value = VocabLoadState.loading;
    Get.toNamed(AppRoutes.vocabWordList);
    try {
      words.assignAll(await _repo.getWordsByTopic(topic.id));
      wordsState.value = VocabLoadState.loaded;
    } catch (_) {
      wordsState.value = VocabLoadState.error;
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
    Get.toNamed(AppRoutes.vocabSpelling);
  }

  void onSpellingInputChange(String value) => spellingInput.value = value;

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
      Get.offNamed(AppRoutes.vocabSpellingResult);
      return;
    }
    spellingIndex.value++;
    spellingInput.value = '';
    spellingState.value = SpellingState.typing;
    spellingController.clear();
  }

  VocabWord? get currentSpellingWord {
    if (spellingWords.isEmpty || spellingIndex.value >= spellingWords.length) return null;
    return spellingWords[spellingIndex.value];
  }

  int get spellingCorrectCount => spellingResults.where((r) => r.isCorrect).length;
}
