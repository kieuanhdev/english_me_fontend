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
            onError: (error, handler) async {
              // 401: token Firebase có thể đã hết hạn / bị revoke / lệch giờ.
              // Force refresh idToken rồi retry request đúng 1 lần. Cờ trong
              // extra chống vòng lặp vô hạn nếu sau refresh vẫn 401.
              final req = error.requestOptions;
              final is401 = error.response?.statusCode == 401;
              final alreadyRetried = req.extra['retried_401'] == true;
              if (is401 && !alreadyRetried) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final fresh = await user?.getIdToken(true); // force refresh
                  if (fresh != null && fresh.isNotEmpty) {
                    req.extra['retried_401'] = true;
                    req.headers['Authorization'] = 'Bearer $fresh';
                    final res = await _instance.fetch<dynamic>(req);
                    handler.resolve(res);
                    return;
                  }
                } catch (_) {
                  // Refresh / retry thất bại → rơi xuống reject như lỗi gốc.
                }
              }
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
      _log('query: ${_redact(options.queryParameters)}');
    }
    if (options.data != null) {
      _log('body: ${_preview(_redact(options.data))}');
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
    _log('body: ${_preview(_redact(response.data))}');
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
    _log('body: ${_preview(_redact(err.response?.data))}');
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

  /// Các khoá chứa dữ liệu nhạy cảm (PII / bí mật) — che khi log body & query.
  /// So khớp không phân biệt hoa thường, theo substring (vd 'idToken' khớp 'token').
  static const _sensitiveKeys = {
    'password',
    'token',
    'idtoken',
    'accesstoken',
    'refreshtoken',
    'authorization',
    'secret',
    'apikey',
    'api_key',
    'email',
    'fullname',
    'phone',
    'firebaseuid',
  };

  bool _isSensitiveKey(String key) {
    final k = key.toLowerCase();
    return _sensitiveKeys.any(k.contains);
  }

  /// Che đệ quy các field nhạy cảm trong Map/List trước khi log.
  /// Giữ nguyên kiểu cấu trúc để output đọc được; chỉ thay giá trị nhạy cảm = '***'.
  Object? _redact(Object? data) {
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key,
          _isSensitiveKey('$key') ? '***' : _redact(value),
        ),
      );
    }
    if (data is List) {
      return data.map(_redact).toList();
    }
    return data;
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
