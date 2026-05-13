import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Giữ locale đồng bộ với [GetMaterialApp] (Rebuild qua Obx trong [EnglishMeApp]).
class AppLocaleController extends GetxController {
  final Rx<Locale> localeRx = const Locale('vi', 'VN').obs;

  bool get isVietnamese => localeRx.value.languageCode == 'vi';

  void setLocale(Locale locale) {
    localeRx.value = locale;
    Get.updateLocale(locale);
  }
}
