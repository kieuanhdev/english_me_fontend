import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_deck_controller.dart';
import 'package:englishme/modules/vocab_hub/views/widgets/vocab_deck_list.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabHubScreen extends StatelessWidget {
  const VocabHubScreen({super.key});

  /// Tab khởi tạo theo ngữ cảnh điều hướng:
  /// - vào từ thẻ "Flashcard" (route flashcards) → tab "Bộ thẻ của tôi" (1)
  /// - vào từ thẻ "Từ vựng" (route vocabHub) → tab "Khám phá" (0)
  /// Cho phép override bằng arguments {'initialTab': 0|1} nếu cần.
  int get _initialTab {
    final args = Get.arguments;
    if (args is Map && args['initialTab'] is int) {
      return (args['initialTab'] as int).clamp(0, 1);
    }
    return Get.currentRoute == AppRoutes.flashcards ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _initialTab,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        // FAB tạo bộ thẻ — chỉ hiện ở tab "Bộ thẻ của tôi" (index 1).
        floatingActionButton: const _CreateDeckFab(),
        body: SafeArea(
          child: Column(
            children: [
              AppGap.h14,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppMainAppBar(
                  title: 'Từ vựng',
                  showBack: true,
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
                    tabs: [
                      Tab(text: T.vocabTabExplore.tr),
                      Tab(text: T.vocabTabMyDecks.tr),
                    ],
                  ),
                ),
              ),
              AppGap.h8,
              const Expanded(
                child: TabBarView(children: [_ExploreTab(), _MyDecksTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab 1: Khám phá — bộ thẻ hệ thống (owner=NULL) ─────────────────────────────

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: AppGap.h8),
        const SliverToBoxAdapter(child: _LevelFilterBar()),
        SliverToBoxAdapter(
          child: VocabDeckList(
            decksSelector: (c) => c.systemDecks,
            emptyMessage: T.emptyExploreDecks.tr,
            emptyIcon: Icons.explore_outlined,
          ),
        ),
        const SliverToBoxAdapter(child: AppGap.h32),
      ],
    );
  }
}

// ─── Hàng chip lọc theo cấp CEFR (tab Khám phá) ─────────────────────────────────

/// Chip "Tất cả / A1 / A2 ..." để user lọc nhanh bộ thẻ theo cấp.
/// Chỉ liệt kê các cấp user được phép xem (≤ trình độ). Luôn hiện ở mọi cấp;
/// chỉ ẩn khi chưa có cấp nào (danh sách rỗng = chưa tải xong / lỗi).
class _LevelFilterBar extends GetView<VocabDeckController> {
  const _LevelFilterBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final levels = controller.availableLevels;
      if (levels.isEmpty) return const SizedBox.shrink();
      final selected = controller.selectedLevel.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: T.deckFilterAll.tr,
                active: selected.isEmpty,
                onTap: () => controller.onSelectLevel(selected),
              ),
              for (final lvl in levels) ...[
                AppGap.w8,
                _FilterChip(
                  label: lvl,
                  active: selected == lvl,
                  onTap: () => controller.onSelectLevel(lvl),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.onPrimaryFixed : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Tab 2: Của tôi — chỉ bộ do người dùng tự tạo ───────────────────────────────

class _MyDecksTab extends StatelessWidget {
  const _MyDecksTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: AppGap.h8),
        SliverToBoxAdapter(
          child: VocabDeckList(
            decksSelector: (c) => c.myDecks,
            emptyMessage: T.emptyMyDecks.tr,
            emptyIcon: Icons.add_box_outlined,
          ),
        ),
        const SliverToBoxAdapter(child: AppGap.h32),
      ],
    );
  }
}

// ─── FAB tạo bộ thẻ ─────────────────────────────────────────────────────────────

/// Nút tạo bộ thẻ. Chỉ hiển thị khi đang ở tab "Bộ thẻ của tôi" (index 1),
/// ẩn ở tab "Khám phá" để không che danh sách chủ đề.
class _CreateDeckFab extends StatelessWidget {
  const _CreateDeckFab();

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        if (tabController.index != 1) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: Get.find<VocabDeckController>().onCreateDeck,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimaryFixed,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            T.flashcardCreateNew.tr,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimaryFixed,
            ),
          ),
        );
      },
    );
  }
}
