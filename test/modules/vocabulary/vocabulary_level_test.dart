import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/modules/vocabulary/models/vocabulary_model.dart';

void main() {
  group('VocabularyLevelX.fromCefr', () {
    test('parses uppercase A1..C2 correctly', () {
      expect(VocabularyLevelX.fromCefr('A1'), VocabularyLevel.a1);
      expect(VocabularyLevelX.fromCefr('A2'), VocabularyLevel.a2);
      expect(VocabularyLevelX.fromCefr('B1'), VocabularyLevel.b1);
      expect(VocabularyLevelX.fromCefr('B2'), VocabularyLevel.b2);
      expect(VocabularyLevelX.fromCefr('C1'), VocabularyLevel.c1);
      expect(VocabularyLevelX.fromCefr('C2'), VocabularyLevel.c2);
    });

    test('is case-insensitive', () {
      expect(VocabularyLevelX.fromCefr('a1'), VocabularyLevel.a1);
      expect(VocabularyLevelX.fromCefr('b2'), VocabularyLevel.b2);
    });

    test('falls back to a1 for null or invalid input', () {
      expect(VocabularyLevelX.fromCefr(null), VocabularyLevel.a1);
      expect(VocabularyLevelX.fromCefr(''), VocabularyLevel.a1);
      expect(VocabularyLevelX.fromCefr('Z9'), VocabularyLevel.a1);
    });
  });

  group('VocabularyTopic.fromJson', () {
    test('parses backend topic shape', () {
      final topic = VocabularyTopic.fromJson({
        'id': 'travel',
        'name': 'Du lịch',
        'nameEn': 'Travel',
        'icon': '✈️',
        'wordCount': 10,
        'level': 'A2',
        'colorHex': '#2196F3',
      });
      expect(topic.id, 'travel');
      expect(topic.name, 'Du lịch');
      expect(topic.nameEn, 'Travel');
      expect(topic.wordCount, 10);
      expect(topic.level, VocabularyLevel.a2);
      expect(topic.colorHex, '#2196F3');
    });

    test('applies safe defaults for missing fields', () {
      final topic = VocabularyTopic.fromJson({'id': 'x'});
      expect(topic.icon, '📚');
      expect(topic.wordCount, 0);
      expect(topic.level, VocabularyLevel.a1);
      expect(topic.colorHex, '#4CAF50');
    });
  });
}
