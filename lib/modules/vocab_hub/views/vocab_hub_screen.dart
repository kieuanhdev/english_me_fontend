import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/vocab_hub/views/widgets/vocab_deck_list.dart';
import 'package:englishme/modules/vocab_hub/views/widgets/vocab_stats.dart';
import 'package:englishme/modules/vocab_hub/views/widgets/vocab_word_of_day.dart';
import 'package:englishme/modules/vocab_hub/views/vocab_topic_list_screen.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabHubScreen extends StatelessWidget {
  const VocabHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              AppGap.h14,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppMainAppBar(
                  title: 'Từ vựng',
                  showSearch: true,
                  horizontalPadding: 0,
                ),
              ),
              AppGap.h16,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    labelColor: AppColors.onPrimaryFixed,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTypography.bodyLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Chủ đề'),
                      Tab(text: 'Của tôi'),
                    ],
                  ),
                ),
              ),
              AppGap.h8,
              const Expanded(
                child: TabBarView(
                  children: [
                    _TopicsTab(),
                    _MyDecksTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab 1: Chủ đề ─────────────────────────────────────────────────────────────

class _TopicsTab extends StatelessWidget {
  const _TopicsTab();

  @override
  Widget build(BuildContext context) => const VocabTopicListScreen(embedded: true);
}

// ─── Tab 2: Của tôi ────────────────────────────────────────────────────────────

class _MyDecksTab extends StatelessWidget {
  const _MyDecksTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: AppGap.h8),
        const SliverToBoxAdapter(child: VocabWordOfDay()),
        SliverToBoxAdapter(child: AppGap.h20),
        const SliverToBoxAdapter(child: VocabStats()),
        SliverToBoxAdapter(child: AppGap.h28),
        const SliverToBoxAdapter(child: VocabDeckList()),
        SliverToBoxAdapter(child: AppGap.h32),
      ],
    );
  }
}
