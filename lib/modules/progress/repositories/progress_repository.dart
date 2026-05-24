import 'package:dio/dio.dart';

import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/modules/progress/models/progress_response.dart';
import 'package:englishme/modules/progress/models/streak_calendar_response.dart';
import 'package:englishme/modules/progress/models/xp_history_item.dart';
import 'package:englishme/modules/progress/models/xp_ledger.dart';

class ProgressRepository {
  final Dio _dio;
  ProgressRepository(this._dio);

  /// Lấy 1 trang ledger XP (cursor-based). Spec §9.4.2.
  ///
  /// `cursor`: bỏ trống cho trang đầu, dùng `nextCursor` từ trang trước cho
  /// các trang tiếp theo.
  Future<XpLedgerPage> getXpLedger({String? cursor, int limit = 20}) async {
    final clampedLimit = limit < 1 ? 1 : (limit > 100 ? 100 : limit);
    final params = <String, dynamic>{'limit': clampedLimit};
    if (cursor != null && cursor.isNotEmpty) params['cursor'] = cursor;
    final response = await _dio.get(
      '/users/me/xp/ledger',
      queryParameters: params,
    );
    return XpLedgerPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProgressData> getProgressData() async {
    final now = DateTime.now();
    final monthParam = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      _dio.get('/users/me/progress'),
      _dio.get('/users/me/xp-history', queryParameters: {'days': 14}),
      _dio.get(
        '/users/me/streak-calendar',
        queryParameters: {'month': monthParam},
      ),
    ]);

    final progress = ProgressResponse.fromJson(
      results[0].data as Map<String, dynamic>,
    );

    final xpHistoryRaw = results[1].data;
    final xpHistory = xpHistoryRaw is List
        ? xpHistoryRaw
              .whereType<Map<String, dynamic>>()
              .map(XpHistoryItem.fromJson)
              .toList()
        : <XpHistoryItem>[];

    final streak = StreakCalendarResponse.fromJson(
      results[2].data as Map<String, dynamic>,
    );

    return _toProgressData(progress, xpHistory, streak);
  }

  ProgressData _toProgressData(
    ProgressResponse progress,
    List<XpHistoryItem> xpHistory,
    StreakCalendarResponse streak,
  ) {
    final skillMap = <String, double>{};
    for (final s in progress.skills) {
      skillMap[s.skill.toLowerCase()] = s.normalized;
    }

    final todayKey = _dateKey(DateTime.now());
    final todayXp = xpHistory
        .where((e) => _dateKey(e.date) == todayKey)
        .fold<int>(0, (acc, e) => acc + e.xp);

    return ProgressData(
      cefrLevel: progress.cefrLevel ?? '',
      cefrLabel: _cefrLabel(progress.cefrLevel),
      currentStreak: progress.currentStreak,
      longestStreak: progress.longestStreak,
      totalXp: progress.totalXp,
      todayXp: todayXp,
      xpGoal: 50,
      studyDates: streak.activeDates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList(),
      xpHistory: xpHistory
          .map((e) => WeeklyXpEntry(date: e.date, xp: e.xp))
          .toList(),
      skillBreakdown: SkillBreakdown(
        vocabulary: skillMap['vocabulary'] ?? 0,
        grammar: skillMap['grammar'] ?? 0,
        pronunciation: skillMap['pronunciation'] ?? 0,
        // Backend không có nguồn XP listening (mục 11.2) → luôn 0.
        listening: 0,
      ),
      weeklySummary: WeeklySummary(
        totalXp: progress.weekSummary.totalXp,
        activeDays: progress.weekSummary.activeDays,
        lessonsCompleted: progress.weekSummary.lessonsCompleted,
      ),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _cefrLabel(String? cefr) {
    switch (cefr) {
      case 'A1':
        return 'BEGINNER';
      case 'A2':
        return 'PRE-INTERMEDIATE';
      case 'B1':
        return 'INTERMEDIATE';
      case 'B2':
        return 'UPPER INTERMEDIATE';
      case 'C1':
        return 'ADVANCED';
      case 'C2':
        return 'PROFICIENT';
      default:
        return '';
    }
  }
}
