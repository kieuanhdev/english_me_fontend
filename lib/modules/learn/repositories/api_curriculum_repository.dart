import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/models/learning_models.dart' show XpBonus;
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';

/// Repository THẬT cho luồng giáo trình — gọi backend Spring Boot.
///
/// Khớp các endpoint của CurriculumController:
///   GET  /learning/curriculum/levels/{level}/units
///   GET  /learning/curriculum/units/{unitId}
///   GET  /learning/curriculum/lessons/{lessonId}
///   POST /learning/curriculum/lessons/{lessonId}/theory/complete
///   POST /learning/curriculum/lessons/{lessonId}/complete
///
/// Base URL + Authorization Bearer được [DioClient] tự đính (interceptor).
/// Lỗi backend (vd 409 THEORY_REQUIRED) đã được interceptor convert thành
/// ApiException — repo chỉ cần để nó ném lên controller.
class ApiCurriculumRepository implements CurriculumRepository {
  ApiCurriculumRepository(this._dio);

  final Dio _dio;

  static const _base = '/learning/curriculum';

  @override
  Future<LevelUnits> getLevelUnits(String level) async {
    final res = await _dio.get('$_base/levels/$level/units');
    return LevelUnits.fromJson(_asMap(res.data));
  }

  @override
  Future<UnitDetail> getUnitDetail(String unitId) async {
    final res = await _dio.get('$_base/units/$unitId');
    return UnitDetail.fromJson(_asMap(res.data));
  }

  @override
  Future<CurriculumLessonDetail> getLessonDetail(String lessonId) async {
    final res = await _dio.get('$_base/lessons/$lessonId');
    final data = _asMap(res.data);
    try {
      return CurriculumLessonDetail.fromJson(data);
    } catch (error, stackTrace) {
      _log('Parse lesson detail failed: $error');
      _log('Raw: $data');
      _log('$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> completeTheory(String lessonId) async {
    await _dio.post('$_base/lessons/$lessonId/theory/complete');
  }

  @override
  Future<bool> submitExercises(
    String lessonId,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await _dio.post(
      '$_base/lessons/$lessonId/exercises/submit',
      data: {'answers': answers}, // đáp án THÔ practice — BE chấm + lưu progress
    );
    final data = _asMap(res.data);
    // BE đánh dấu practice_completed khi làm hết câu đúng và không còn câu sai.
    final total = _i(data['total']);
    final correct = _i(data['correct']);
    final retry = (data['retryActivityIds'] as List?) ?? const [];
    return total > 0 && correct == total && retry.isEmpty;
  }

  @override
  Future<LessonResult> completeLesson(
    String lessonId,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await _dio.post(
      '$_base/lessons/$lessonId/complete',
      data: {
        'timeSpentSeconds': 0,
        'answers': answers, // đáp án THÔ — BE tự chấm điểm mastery
      },
    );
    final data = _asMap(res.data);
    final rawBonuses = data['bonuses'];
    return LessonResult(
      passed: data['passed'] == true,
      score: _i(data['score']),
      xpEarned: _i(data['xpEarned']),
      unitProgress: _d(data['unitProgress']),
      unitCompleted: data['unitCompleted'] == true,
      nextLessonId: data['nextLessonId']?.toString(),
      totalXp: _i(data['totalXp']),
      dailyEarnedXp: _i(data['dailyEarnedXp']),
      streakUpdated: data['streakUpdated'] == true,
      bonuses: rawBonuses is List
          ? rawBonuses
              .whereType<Map<String, dynamic>>()
              .map(XpBonus.fromJson)
              .toList()
          : const [],
    );
  }

  @override
  Future<List<CurriculumActivity>> generateExtraPractice(
    String lessonId,
    List<String> existingQuestions, {
    int count = 5,
  }) async {
    final res = await _dio.post(
      '$_base/lessons/$lessonId/practice/generate',
      data: {'existingQuestions': existingQuestions, 'count': count},
    );
    final data = _asMap(res.data);
    final list = (data['questions'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CurriculumActivity.fromJson)
        .toList();
  }

  @override
  Future<CheckpointState> getCheckpoint(String level) async {
    final res = await _dio.get('$_base/levels/$level/checkpoint');
    return CheckpointState.fromJson(_asMap(res.data));
  }

  @override
  Future<CheckpointResult> submitCheckpoint(
    String level,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await _dio.post(
      '$_base/levels/$level/checkpoint/submit',
      data: {'answers': answers},
    );
    return CheckpointResult.fromJson(_asMap(res.data));
  }
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  _log('Expected Map<String, dynamic> but got ${data.runtimeType}: $data');
  return const {};
}

int _i(dynamic v) =>
    v is int ? v : (v is num ? v.round() : int.tryParse('${v ?? ''}') ?? 0);
double _d(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

void _log(String message) {
  if (kDebugMode) debugPrint('[ApiCurriculumRepository] $message');
}
