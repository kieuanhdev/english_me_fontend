import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../gen/assets.gen.dart'; // File do flutter_gen sinh ra

class LocalizationService extends Translations {
  static Map<String, Map<String, String>> _keys = {};

  static Future<void> init() async {
    _keys = {
      'en_US': await _loadJson(Assets.locales.en),
      'vi_VN': await _loadJson(Assets.locales.vi),
    };
  }

  static Future<Map<String, String>> _loadJson(String path) async {
    final String response = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(response);
    // Chuyển Map<String, dynamic> thành Map<String, String>
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
