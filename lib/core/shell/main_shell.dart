import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/modules/home/views/home_screen.dart';
import 'package:englishme/modules/learn/views/unit_list_screen.dart';
import 'package:englishme/modules/profile/views/profile_screen.dart';
import 'package:englishme/modules/progress/views/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static final List<Widget> _tabs = [
    const HomeScreen(),
    const UnitListScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ShellController c = Get.find<ShellController>();
    return Scaffold(
      // AppBottomNav tự reactive với ShellController — không cần Obx bọc ngoài.
      body: Obx(() => IndexedStack(index: c.currentTab.value, children: _tabs)),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
