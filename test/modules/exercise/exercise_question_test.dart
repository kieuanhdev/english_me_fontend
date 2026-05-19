import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/modules/exercise/models/exercise_model.dart';

void main() {
  group('ExerciseQuestion.fromJson — options shape', () {
    test('parses Map<String,String> options {A,B,C,D} preserving labels', () {
      final q = ExerciseQuestion.fromJson({
        'id': 'q1',
        'type': 'multipleChoice',
        'category': 'vocabulary',
        'difficulty': 'medium',
        'question': 'Choose synonym of "fast"',
        'options': {
          'A': 'slow',
          'B': 'quick',
          'C': 'loud',
          'D': 'quiet',
        },
        'correctAnswer': 'B',
      });

      expect(q.id, 'q1');
      expect(q.options, ['slow', 'quick', 'loud', 'quiet']);
      expect(q.optionLabels, ['A', 'B', 'C', 'D']);
      expect(q.correctAnswer, 'B');
      // labelFor maps text → key for submit payload.
      expect(q.labelFor('quick'), 'B');
      expect(q.labelFor('not-an-option'), isNull);
    });

    test('parses List<String> options assigning A/B/C/D labels', () {
      final q = ExerciseQuestion.fromJson({
        'id': 'q2',
        'type': 'multipleChoice',
        'category': 'grammar',
        'difficulty': 'easy',
        'question': 'Pick the right tense',
        'options': ['go', 'goes', 'going', 'gone'],
        'correctAnswer': 'goes',
      });

      expect(q.options, ['go', 'goes', 'going', 'gone']);
      expect(q.optionLabels, ['A', 'B', 'C', 'D']);
      expect(q.labelFor('goes'), 'B');
    });

    test('falls back to default enum values for unknown strings', () {
      final q = ExerciseQuestion.fromJson({
        'id': 'q3',
        'type': 'unknown',
        'category': 'unknown',
        'difficulty': 'unknown',
        'question': '?',
        'options': <String, String>{},
        'correctAnswer': '',
      });

      expect(q.type, ExerciseType.multipleChoice);
      expect(q.category, ExerciseCategory.vocabulary);
      expect(q.difficulty, ExerciseDifficulty.medium);
    });
  });

  group('ExerciseCompleteResponse.fromJson', () {
    test('parses XP + accuracy from backend response', () {
      final res = ExerciseCompleteResponse.fromJson({
        'totalQuestions': 10,
        'correct': 8,
        'incorrect': 2,
        'accuracyPercent': 80.0,
        'xpEarned': 21,
      });

      expect(res.totalQuestions, 10);
      expect(res.correct, 8);
      expect(res.accuracyPercent, 80.0);
      // XP backend: 2/đúng × 8 + 5 bonus 100% (sai 2 nên không có bonus) = 21? Test chỉ assert giá trị BE trả về, không tính lại.
      expect(res.xpEarned, 21);
    });
  });
}
