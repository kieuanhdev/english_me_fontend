import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/modules/vocab_hub/models/vocab_level.dart';

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
}
