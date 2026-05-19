import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:englishme/core/config/app_config.dart';
import 'package:englishme/core/network/api_exception.dart';

class DioClient {
  DioClient._();

  static final Dio _instance =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrlWithPrefix,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              // Bỏ qua nếu request đã tự đính kèm Authorization
              // (auth_repository.syncUserWithBackend cần idToken vừa tạo,
              // FirebaseAuth.currentUser có thể chưa update kịp tại thời điểm gọi).
              if (options.headers['Authorization'] == null) {
                final user = FirebaseAuth.instance.currentUser;
                final token = await user?.getIdToken();
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
              }
              handler.next(options);
            },
            onError: (error, handler) {
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  response: error.response,
                  type: error.type,
                  error: ApiException.fromDio(error),
                  message: ApiException.fromDio(error).message,
                ),
              );
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true),
        );

  static Dio get instance => _instance;
}
