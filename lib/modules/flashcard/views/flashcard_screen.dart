import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/flashcard/views/widgets/flashcard_deck_list.dart';
import 'package:englishme/modules/flashcard/views/widgets/flashcard_stats.dart';
import 'package:englishme/modules/flashcard/views/widgets/flashcard_word_of_day.dart';
import 'package:englishme/theme/app_theme.dart';

class FlashcardScreen extends GetView<FlashcardController> {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AppBottomNav(initialIndex: 1),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: AppGap.h14),
            const SliverToBoxAdapter(
              child: AppMainAppBar(title: 'Flashcards', showSearch: true),
            ),
            SliverToBoxAdapter(child: AppGap.h24),
            const SliverToBoxAdapter(child: FlashcardWordOfDay()),
            SliverToBoxAdapter(child: AppGap.h20),
            const SliverToBoxAdapter(child: FlashcardStats()),
            SliverToBoxAdapter(child: AppGap.h28),
            const SliverToBoxAdapter(child: FlashcardDeckList()),
            SliverToBoxAdapter(child: AppGap.h32),
          ],
        ),
      ),
    );
  }
}
