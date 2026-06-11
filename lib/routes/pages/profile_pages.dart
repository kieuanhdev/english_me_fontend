import 'package:englishme/modules/profile/bindings/profile_binding.dart';
import 'package:englishme/modules/profile/views/profile_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class ProfilePages {
  static final pages = [
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
