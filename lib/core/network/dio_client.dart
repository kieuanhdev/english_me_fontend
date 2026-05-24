import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
        ..interceptors.add(_AppLogInterceptor());

  static Dio get instance => _instance;
}

class _AppLogInterceptor extends Interceptor {
  static const _maxBodyLength = 1200;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('*** API Request ***');
    _log('${options.method} ${options.uri}');
    _log('headers: ${_redactHeaders(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      _log('query: ${options.queryParameters}');
    }
    if (options.data != null) {
      _log('body: ${_preview(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    _log('*** API Response ***');
    _log('${options.method} ${options.uri}');
    _log(
      'status: ${response.statusCode} ${response.statusMessage ?? ''}'.trim(),
    );
    _log('dataType: ${response.data.runtimeType}');
    _log('body: ${_preview(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    _log('*** API Error ***');
    _log('${options.method} ${options.uri}');
    _log('type: ${err.type}');
    _log('message: ${err.message}');
    _log(
      'status: ${err.response?.statusCode} ${err.response?.statusMessage ?? ''}'
          .trim(),
    );
    _log('dataType: ${err.response?.data.runtimeType}');
    _log('body: ${_preview(err.response?.data)}');
    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, _redactToken(value));
      }
      return MapEntry(key, value);
    });
  }

  String _redactToken(Object? value) {
    final text = value?.toString() ?? '';
    if (text.length <= 18) return '***';
    return '${text.substring(0, 14)}...${text.substring(text.length - 6)}';
  }

  String _preview(Object? data) {
    final text = data?.toString() ?? 'null';
    if (text.length <= _maxBodyLength) return text;
    return '${text.substring(0, _maxBodyLength)}...<truncated ${text.length - _maxBodyLength} chars>';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
