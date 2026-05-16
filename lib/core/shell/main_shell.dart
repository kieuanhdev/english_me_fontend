import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/exercise/exercise_screen.dart';
import 'package:englishme/modules/flashcard/views/flashcard_screen.dart';
import 'package:englishme/modules/home/views/home_screen.dart';
import 'package:englishme/profile/profile_screen.dart';
import 'package:englishme/test/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const List<Widget> _tabs = [
    HomeScreen(),
    FlashcardScreen(),
    ExerciseScreen(),
    TestScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ShellController c = Get.find<ShellController>();
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: c.currentTab.value,
        children: _tabs,
      )),
      bottomNavigationBar: Obx(() => AppBottomNav(
        initialIndex: c.currentTab.value,
        onTap: (index, _) => c.switchTab(index),
      )),
    );
  }
}
