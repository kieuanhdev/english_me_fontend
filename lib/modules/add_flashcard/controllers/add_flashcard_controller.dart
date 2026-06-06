import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/vocab_hub/repositories/vocab_deck_repository.dart';

class AddFlashcardArgs {
  const AddFlashcardArgs({
    required this.deck,
    this.editCard,
  });

  final VocabDeck deck;
  final VocabWord? editCard;
}

class AddFlashcardController extends GetxController {
  AddFlashcardController({
    required this.deck,
    this.editCard,
  });

  final VocabDeck deck;
  final VocabWord? editCard;

  final formKey = GlobalKey<FormState>();
  final wordCtrl = TextEditingController();
  final ipaCtrl = TextEditingController();
  final meaningCtrl = TextEditingController();
  final exampleCtrl = TextEditingController();

  late final VocabDeckRepository _repo;

  final RxString selectedPosKey = 'NOUN'.obs;
  final RxBool isSubmitting = false.obs;

  bool get isEditMode => editCard != null;

  static const Map<String, String> posLabels = {
    'NOUN': 'Noun',
    'VERB': 'Verb',
    'ADJ': 'Adj',
    'ADV': 'Adv',
    'OTHER': 'Other',
  };

  @override
  void onInit() {
    super.onInit();
    _repo = VocabDeckRepository(DioClient.instance);
    _bindInitialValues();
  }

  @override
  void onClose() {
    wordCtrl.dispose();
    ipaCtrl.dispose();
    meaningCtrl.dispose();
    exampleCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    try {
      if (isEditMode) {
        await _repo.updateFlashcard(
          deckId: deck.id,
          flashcardId: editCard!.id,
          word: wordCtrl.text.trim(),
          ipa: ipaCtrl.text.trim(),
          pos: [selectedPosKey.value],
          vietnamese: meaningCtrl.text.trim(),
          example: exampleCtrl.text.trim(),
          cefr: deck.cefrLevel,
        );
      } else {
        await _repo.createFlashcard(
          deckId: deck.id,
          word: wordCtrl.text.trim(),
          ipa: ipaCtrl.text.trim(),
          pos: [selectedPosKey.value],
          vietnamese: meaningCtrl.text.trim(),
          example: exampleCtrl.text.trim(),
          cefr: deck.cefrLevel,
        );
      }
      Get.back(result: true);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      AppNotify.error(T.errorSaveFailedTitle.tr, message: msg ?? e.message ?? T.errorNetwork.tr);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _bindInitialValues() {
    if (editCard == null) return;
    final card = editCard!;
    wordCtrl.text = card.word;
    ipaCtrl.text = card.ipa;
    meaningCtrl.text = card.definitionVi;
    exampleCtrl.text = card.exampleSentence;
    selectedPosKey.value = _normalizePos(card.pos);
  }

  String _normalizePos(List<String> pos) {
    if (pos.isEmpty) return 'OTHER';
    final raw = pos.first.trim().toUpperCase();
    if (posLabels.containsKey(raw)) return raw;
    return switch (raw) {
      'ADJECTIVE' => 'ADJ',
      'ADVERB' => 'ADV',
      _ => 'OTHER',
    };
  }
}
