import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/core/network/api_exception.dart';

void main() {
  group('ApiException.fromDio', () {
    test('parses backend {status, error, message} shape', () {
      final requestOptions = RequestOptions(path: '/users/me');
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 404,
          data: {
            'status': 404,
            'error': 'NOT_FOUND',
            'message': 'User không tồn tại',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final api = ApiException.fromDio(dioError);

      expect(api.statusCode, 404);
      expect(api.code, 'NOT_FOUND');
      expect(api.message, 'User không tồn tại');
      expect(api.toString(), 'User không tồn tại');
    });

    test('falls back to status-based code when body missing', () {
      final requestOptions = RequestOptions(path: '/foo');
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      final api = ApiException.fromDio(dioError);

      expect(api.statusCode, 401);
      expect(api.code, 'UNAUTHORIZED');
      expect(api.message, isNotEmpty);
    });

    test('handles connection timeout with Vietnamese message', () {
      final requestOptions = RequestOptions(path: '/foo');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final api = ApiException.fromDio(dioError);

      expect(api.statusCode, 0);
      expect(api.code, 'UNKNOWN');
      expect(api.message, contains('quá hạn'));
    });

    test('maps 400/422 to BAD_REQUEST / VALIDATION_ERROR codes', () {
      final requestOptions = RequestOptions(path: '/foo');

      final api400 = ApiException.fromDio(
        DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 400),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(api400.code, 'BAD_REQUEST');

      final api422 = ApiException.fromDio(
        DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 422),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(api422.code, 'VALIDATION_ERROR');
    });
  });
}
