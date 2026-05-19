import 'package:dio/dio.dart';

/// Lỗi API chuẩn hoá từ format backend `{status, error, message}` (mục 15 PROJECT_DOCUMENTATION).
///
/// Repositories không cần tự parse `e.response?.data['message']` nữa —
/// interceptor trong [DioClient] đã convert mọi [DioException] thành
/// [ApiException] trước khi ném lên controller.
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  /// Parse từ [DioException]. Fallback an toàn khi response không có shape chuẩn
  /// (mạng rớt, server 5xx HTML, ...).
  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;
    final statusCode = response?.statusCode ?? 0;

    if (data is Map<String, dynamic>) {
      final code = (data['error'] ?? data['code'] ?? _codeFromStatus(statusCode)).toString();
      final message = (data['message'] ?? _defaultMessage(e)).toString();
      return ApiException(
        statusCode: statusCode,
        code: code,
        message: message,
      );
    }

    return ApiException(
      statusCode: statusCode,
      code: _codeFromStatus(statusCode),
      message: _defaultMessage(e),
    );
  }

  static String _codeFromStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'BAD_REQUEST';
      case 401:
        return 'UNAUTHORIZED';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 422:
        return 'VALIDATION_ERROR';
      case 500:
        return 'INTERNAL_ERROR';
      default:
        return 'UNKNOWN';
    }
  }

  static String _defaultMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá hạn. Vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới máy chủ.';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị huỷ.';
      case DioExceptionType.badCertificate:
        return 'Chứng chỉ máy chủ không hợp lệ.';
      case DioExceptionType.badResponse:
        return 'Máy chủ trả về lỗi (${e.response?.statusCode}).';
      case DioExceptionType.unknown:
        return e.message ?? 'Đã xảy ra lỗi không xác định.';
    }
  }

  @override
  String toString() => message;
}
