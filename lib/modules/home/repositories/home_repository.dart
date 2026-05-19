import 'package:dio/dio.dart';

import 'package:englishme/modules/home/models/home_dashboard_model.dart';

class HomeRepository {
  final Dio _dio;
  HomeRepository(this._dio);

  Future<HomeDashboardResponse> getDashboard() async {
    final response = await _dio.get('/home/dashboard');
    return HomeDashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
