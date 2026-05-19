/// Configuration tập trung cho toàn ứng dụng.
///
/// `apiBaseUrl` được nạp qua `--dart-define=API_BASE_URL=...` để không cần
/// rebuild khi đổi mạng. Default trỏ về máy dev hiện tại.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.34:8080',
  );

  /// Base URL kèm prefix `/api` — dùng cho Dio.
  static String get apiBaseUrlWithPrefix => '$apiBaseUrl/api';
}
