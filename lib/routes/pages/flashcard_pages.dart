import 'package:englishme/modules/add_flashcard/bindings/add_flashcard_binding.dart';
import 'package:englishme/modules/add_flashcard/views/add_flashcard_screen.dart';
import 'package:englishme/modules/create_deck/bindings/create_deck_binding.dart';
import 'package:englishme/modules/create_deck/views/create_deck_screen.dart';
import 'package:englishme/modules/deck_prep/bindings/deck_prep_binding.dart';
import 'package:englishme/modules/deck_prep/views/deck_prep_screen.dart';
import 'package:englishme/modules/vocab_hub/bindings/vocab_hub_binding.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_hub_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class FlashcardPages {
  static final pages = [
    GetPage(
      name: AppRoutes.flashcards,
      page: () => const VocabHubScreen(),
      binding: VocabHubBinding(),
    ),
    GetPage(
      name: AppRoutes.vocabHub,
      page: () => const VocabHubScreen(),
      binding: VocabHubBinding(),
    ),
    GetPage(
      name: AppRoutes.deckPrep,
      page: () => const DeckPrepScreen(),
      binding: DeckPrepBinding(),
    ),
    GetPage(
      name: AppRoutes.addFlashcard,
      page: () => const AddFlashcardScreen(),
      binding: AddFlashcardBinding(),
    ),
    GetPage(
      name: AppRoutes.createDeck,
      page: () => const CreateDeckScreen(),
      binding: CreateDeckBinding(),
    ),
  ];
}
