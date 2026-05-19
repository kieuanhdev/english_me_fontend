import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/home/views/widgets/home_continue_learning.dart';
import 'package:englishme/modules/home/views/widgets/home_hero_section.dart';
import 'package:englishme/modules/home/views/widgets/home_quick_stats.dart';
import 'package:englishme/modules/home/views/widgets/home_recommendations.dart';
import 'package:englishme/modules/home/views/widgets/home_word_of_day.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  ApiState _mapState(HomeLoadState s, HomeController c) {
    switch (s) {
      case HomeLoadState.idle:
      case HomeLoadState.loading:
        return c.dashboard.value == null ? ApiState.loading : ApiState.success;
      case HomeLoadState.error:
        return c.dashboard.value == null ? ApiState.error : ApiState.success;
      case HomeLoadState.success:
        return ApiState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _mapState(controller.loadState.value, controller),
            errorMessage: T.errorLoadHome.tr,
            onRetry: controller.loadDashboard,
            builder: (_) => RefreshIndicator(
              onRefresh: controller.reloadDashboard,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: AppGap.h14),
                  SliverToBoxAdapter(
                    child: Obx(() => AppMainAppBar(
                      subtitle: controller.greetingLabel.value,
                    )),
                  ),
                  SliverToBoxAdapter(child: AppGap.h24),
                  const SliverToBoxAdapter(child: HomeHeroSection()),
                  SliverToBoxAdapter(child: AppGap.h20),
                  const SliverToBoxAdapter(child: HomeQuickStats()),
                  SliverToBoxAdapter(child: AppGap.h28),
                  const SliverToBoxAdapter(child: HomeContinueLearning()),
                  SliverToBoxAdapter(child: AppGap.h28),
                  const SliverToBoxAdapter(child: HomeWordOfDay()),
                  SliverToBoxAdapter(child: AppGap.h28),
                  const SliverToBoxAdapter(child: HomeRecommendations()),
                  SliverToBoxAdapter(child: AppGap.h32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
