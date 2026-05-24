enum VocabLevel { a1, a2, b1, b2, c1, c2 }

extension VocabLevelX on VocabLevel {
  String get label => switch (this) {
        VocabLevel.a1 => 'A1',
        VocabLevel.a2 => 'A2',
        VocabLevel.b1 => 'B1',
        VocabLevel.b2 => 'B2',
        VocabLevel.c1 => 'C1',
        VocabLevel.c2 => 'C2',
      };

  static VocabLevel fromString(String? raw) => switch ((raw ?? '').toUpperCase()) {
        'A1' => VocabLevel.a1,
        'A2' => VocabLevel.a2,
        'B1' => VocabLevel.b1,
        'B2' => VocabLevel.b2,
        'C1' => VocabLevel.c1,
        'C2' => VocabLevel.c2,
        _ => VocabLevel.a1,
      };
}
