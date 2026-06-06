import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends GetxController {
  static const String _prefKey = 'app_locale';

  final Rx<Locale> localeRx = const Locale('vi', 'VN').obs;

  bool get isVietnamese => localeRx.value.languageCode == 'vi';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == 'en') {
      localeRx.value = const Locale('en', 'US');
    } else {
      localeRx.value = const Locale('vi', 'VN');
    }
  }

  Future<void> setLocale(Locale locale) async {
    localeRx.value = locale;
    Get.updateLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  void toggleLocale() {
    setLocale(
      isVietnamese ? const Locale('en', 'US') : const Locale('vi', 'VN'),
    );
  }
}
