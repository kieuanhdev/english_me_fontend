import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/modules/exercise/models/exercise_model.dart';
import 'package:englishme/modules/learn/models/learning_models.dart';
import 'package:englishme/modules/progress/models/xp_ledger.dart';
import 'package:englishme/modules/study_session/models/review_response.dart';
import 'package:englishme/modules/test/models/test_model.dart';

/// Spec §9.4 — verify 4 DTO mới parse đúng trường BE bổ sung
/// (totalXp / dailyEarnedXp / streakUpdated / bonuses) và endpoint
/// `GET /xp/ledger` parse được trang cursor-based.
void main() {
  group('LearningCompleteResponse.fromJson — spec §9.4.1', () {
    test('parses totalXp, dailyEarnedXp, bonuses[]', () {
      final res = LearningCompleteResponse.fromJson({
        'lessonId': 'a2-path-02-travel-act-02',
        'completed': true,
        'score': 100,
        'xpEarned': 10,
        'totalXp': 1280,
        'dailyEarnedXp': 22,
        'levelProgress': 0.42,
        'skillProgress': 0.35,
        'nextLessonId': 'a2-path-02-travel-act-03',
        'streakUpdated': true,
        'bonuses': [
          {
            'type': 'daily_goal_bonus',
            'amount': 5,
            'label': 'Đạt mục tiêu ngày (30 XP)',
          },
        ],
      });

      expect(res.lessonId, 'a2-path-02-travel-act-02');
      expect(res.xpEarned, 10);
      expect(res.totalXp, 1280);
      expect(res.dailyEarnedXp, 22);
      expect(res.streakUpdated, isTrue);
      expect(res.bonuses, hasLength(1));
      expect(res.bonuses.first.type, 'daily_goal_bonus');
      expect(res.bonuses.first.amount, 5);
      expect(res.bonuses.first.label, 'Đạt mục tiêu ngày (30 XP)');
    });

    test('treats missing optional fields as defaults (retry-safe)', () {
      // Khi BE trả response không có bonuses/totalXp (vd: lỗi parse),
      // FE phải fallback sang 0 / [] thay vì crash.
      final res = LearningCompleteResponse.fromJson({
        'lessonId': 'x',
        'completed': false,
        'score': 0,
        'xpEarned': 0,
      });
      expect(res.totalXp, 0);
      expect(res.dailyEarnedXp, 0);
      expect(res.bonuses, isEmpty);
      expect(res.streakUpdated, isFalse);
    });
  });

  group('TestSubmitResponse.fromJson — spec §9.4.1', () {
    test('parses totalXp + dailyEarnedXp + streakUpdated', () {
      final res = TestSubmitResponse.fromJson({
        'sessionId': 'sess-1',
        'totalQuestions': 10,
        'correct': 8,
        'incorrect': 2,
        'accuracyPercent': 80.0,
        'xpEarned': 16,
        'totalXp': 1296,
        'dailyEarnedXp': 38,
        'streakUpdated': false,
        'timeTakenSeconds': 540,
      });

      expect(res.totalXp, 1296);
      expect(res.dailyEarnedXp, 38);
      expect(res.streakUpdated, isFalse);
      expect(res.xpEarned, 16);
    });
  });

  group('ExerciseCompleteResponse.fromJson — spec §9.4.1', () {
    test('parses totalXp + dailyEarnedXp + streakUpdated', () {
      final res = ExerciseCompleteResponse.fromJson({
        'totalQuestions': 10,
        'correct': 9,
        'incorrect': 1,
        'accuracyPercent': 90.0,
        'xpEarned': 12,
        'totalXp': 1308,
        'dailyEarnedXp': 50,
        'streakUpdated': true,
      });

      expect(res.totalXp, 1308);
      expect(res.dailyEarnedXp, 50);
      expect(res.streakUpdated, isTrue);
    });
  });

  group('ReviewResponse.fromJson — spec §9.4.1', () {
    test('parses totalXp + dailyEarnedXp + streakUpdated + SM-2 fields', () {
      final res = ReviewResponse.fromJson({
        'repetitions': 3,
        'easinessFactor': 2.6,
        'intervalDays': 6,
        'nextReviewAt': '2026-05-30T08:42:11Z',
        'xpEarned': 2,
        'sessionXp': 18,
        'reviewedCount': 9,
        'totalCards': 20,
        'totalXp': 1310,
        'dailyEarnedXp': 52,
        'streakUpdated': false,
      });

      expect(res.intervalDays, 6);
      expect(res.totalXp, 1310);
      expect(res.dailyEarnedXp, 52);
      expect(res.streakUpdated, isFalse);
      expect(res.nextReviewAt, isNotNull);
    });

    test('retry same card same day → xpEarned=0 nhưng totalXp giữ nguyên', () {
      // Spec §9.4.1: retry mạng → xpEarned giữ giá trị, totalXp không đổi.
      // Đây test parsing thuần — đảm bảo xpEarned=0 không bug ra default khác.
      final res = ReviewResponse.fromJson({
        'repetitions': 3,
        'easinessFactor': 2.6,
        'intervalDays': 6,
        'xpEarned': 0,
        'sessionXp': 18,
        'reviewedCount': 9,
        'totalCards': 20,
        'totalXp': 1310,
        'dailyEarnedXp': 52,
        'streakUpdated': false,
      });
      expect(res.xpEarned, 0);
      expect(res.totalXp, 1310);
    });
  });

  group('XpLedgerPage.fromJson — spec §9.4.2', () {
    test('parses items + nextCursor', () {
      final page = XpLedgerPage.fromJson({
        'items': [
          {
            'id': 1234,
            'amount': 10,
            'sourceType': 'lesson',
            'sourceId': 'a2-path-02-travel-act-02',
            'occurredAt': '2026-05-24T08:42:11Z',
          },
          {
            'id': 1233,
            'amount': 5,
            'sourceType': 'daily_goal_bonus',
            'sourceId': '2026-05-24',
            'occurredAt': '2026-05-24T08:42:11Z',
          },
        ],
        'nextCursor': '1233',
      });

      expect(page.items, hasLength(2));
      expect(page.items.first.id, 1234);
      expect(page.items.first.sourceType, 'lesson');
      expect(page.items.first.amount, 10);
      expect(page.nextCursor, '1233');
      expect(page.hasMore, isTrue);
    });

    test('null nextCursor ⇒ hết trang', () {
      final page = XpLedgerPage.fromJson({
        'items': <Map<String, dynamic>>[],
        'nextCursor': null,
      });
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
    });
  });
}
