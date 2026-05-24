import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/modules/vocab_hub/models/vocab_level.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_topic_model.dart';

void main() {
  group('VocabLevelX.fromString', () {
    test('parses uppercase A1..C2 correctly', () {
      expect(VocabLevelX.fromString('A1'), VocabLevel.a1);
      expect(VocabLevelX.fromString('A2'), VocabLevel.a2);
      expect(VocabLevelX.fromString('B1'), VocabLevel.b1);
      expect(VocabLevelX.fromString('B2'), VocabLevel.b2);
      expect(VocabLevelX.fromString('C1'), VocabLevel.c1);
      expect(VocabLevelX.fromString('C2'), VocabLevel.c2);
    });

    test('is case-insensitive', () {
      expect(VocabLevelX.fromString('a1'), VocabLevel.a1);
      expect(VocabLevelX.fromString('b2'), VocabLevel.b2);
    });

    test('falls back to a1 for null or invalid input', () {
      expect(VocabLevelX.fromString(null), VocabLevel.a1);
      expect(VocabLevelX.fromString(''), VocabLevel.a1);
      expect(VocabLevelX.fromString('Z9'), VocabLevel.a1);
    });
  });

  group('VocabTopic.fromJson', () {
    test('parses backend topic shape', () {
      final topic = VocabTopic.fromJson({
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
      expect(topic.level, VocabLevel.a2);
      expect(topic.colorHex, '#2196F3');
    });

    test('applies safe defaults for missing fields', () {
      final topic = VocabTopic.fromJson({'id': 'x'});
      expect(topic.icon, '📚');
      expect(topic.wordCount, 0);
      expect(topic.level, VocabLevel.a1);
      expect(topic.colorHex, '#4CAF50');
    });
  });
}
