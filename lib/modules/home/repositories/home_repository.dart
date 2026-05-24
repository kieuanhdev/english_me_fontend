import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:englishme/core/network/api_exception.dart';
import 'package:englishme/modules/home/models/home_dashboard_model.dart';

class HomeRepository {
  final Dio _dio;
  HomeRepository(this._dio);

  Future<HomeDashboardResponse> getDashboard() async {
    final response = await _dio.get('/home/dashboard');
    return HomeDashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WordOfDayDto?> getWordOfDay({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();

    if (!forceRefresh) {
      final cachedDate = prefs.getString(_wordOfDayDateKey);
      final cachedPayload = prefs.getString(_wordOfDayPayloadKey);
      if (cachedDate == todayKey && cachedPayload != null) {
        final data = jsonDecode(cachedPayload);
        if (data is Map<String, dynamic>) {
          return WordOfDayDto.fromJson(data);
        }
      }
    }

    try {
      final response = await _dio.get('/vocabulary/word-of-day');
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      await prefs.setString(_wordOfDayDateKey, todayKey);
      await prefs.setString(_wordOfDayPayloadKey, jsonEncode(data));
      return WordOfDayDto.fromJson(data);
    } on DioException catch (e) {
      final error = e.error;
      if (error is ApiException && error.statusCode == 400) {
        await prefs.remove(_wordOfDayDateKey);
        await prefs.remove(_wordOfDayPayloadKey);
        return null;
      }
      rethrow;
    }
  }
}

const _wordOfDayDateKey = 'home_word_of_day_date';
const _wordOfDayPayloadKey = 'home_word_of_day_payload';

String _todayKey() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}
