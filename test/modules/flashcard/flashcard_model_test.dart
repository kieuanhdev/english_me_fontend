import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';

void main() {
  group('VocabWord.fromFlashcardJson', () {
    test('uses safe defaults for nullable optional backend fields', () {
      final card = VocabWord.fromFlashcardJson({
        'id': 'card-1',
        'deskId': 'desk-1',
        'word': 'hello',
        'cefr': 'A1',
        'pos': null,
        'ipa': null,
        'audioUrl': null,
        'definition': null,
        'example': null,
        'topic': null,
        'vietnamese': null,
        'viDefinition': null,
        'viExample': null,
      });

      expect(card.id, 'card-1');
      expect(card.pos, isEmpty);
      expect(card.ipa, isEmpty);
      expect(card.definitionVi, isEmpty);
    });

    test('parses non-list pos as a single item', () {
      final card = VocabWord.fromFlashcardJson({
        'id': 'card-1',
        'deskId': 'desk-1',
        'word': 'run',
        'cefr': 'A1',
        'pos': 'verb',
      });

      expect(card.pos, ['verb']);
    });

    test('uses flashcardId fallback when session cards omit id', () {
      final card = VocabWord.fromFlashcardJson({
        'flashcardId': 'card-from-session',
        'desk_id': 'desk-1',
        'word': 'remember',
        'cefr': 'A1',
      });

      expect(card.id, 'card-from-session');
      expect(card.deskId, 'desk-1');
    });
  });

  group('VocabWordPage.fromJson', () {
    test('uses safe defaults for missing pagination fields', () {
      final page = VocabWordPage.fromJson({
        'content': [
          {
            'id': 'card-1',
            'deskId': 'desk-1',
            'word': 'hello',
            'cefr': 'A1',
            'pos': null,
          },
        ],
      });

      expect(page.content, hasLength(1));
      expect(page.totalElements, 1);
      expect(page.totalPages, 1);
      expect(page.number, 0);
      expect(page.last, isTrue);
    });
  });
}
