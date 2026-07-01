import 'package:englishme/modules/auth/controllers/auth_controller.dart';
import 'package:englishme/onboarding/onboarding_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final AuthController c = Get.find<AuthController>();
    final route = await c.tryAutoLogin();
    if (route != null) {
      Get.offAllNamed(route); // đã đăng nhập -> vào thẳng app
      return;
    }
    // Chưa đăng nhập: lần đầu tải app -> giới thiệu; đã xem rồi -> welcome.
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(kSeenOnboardingKey) ?? false;
    Get.offAllNamed(seen ? AppRoutes.welcome : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
