import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static final Dio _instance = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  static Dio get instance => _instance;
}
