import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

/// Cờ SharedPreferences: user đã xem giới thiệu app chưa.
/// Splash đọc cờ này để quyết định show onboarding (lần đầu) hay vào thẳng welcome.
const String kSeenOnboardingKey = 'seen_onboarding';

/// 1 trang giới thiệu (icon + tiêu đề + mô tả + màu nhấn riêng).
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String desc;
  final Color accent;
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.desc,
    required this.accent,
  });
}

/// Vài trang giới thiệu app hiển thị LẦN ĐẦU sau khi tải app, trước màn welcome/đăng nhập.
/// Sau khi xem xong (hoặc bấm "Bỏ qua") sẽ đặt cờ [kSeenOnboardingKey] để không hiện lại.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  List<_OnboardingPage> get _pages => [
        _OnboardingPage(
          icon: Icons.auto_awesome_rounded,
          title: 'Chào mừng đến EnglishMe',
          desc:
              'Ứng dụng học tiếng Anh cá nhân hóa theo trình độ CEFR của riêng bạn.',
          accent: AppColors.primary,
        ),
        _OnboardingPage(
          icon: Icons.style_rounded,
          title: 'Ghi nhớ lâu với Flashcard',
          desc:
              'Học từ vựng theo thuật toán lặp lại ngắt quãng SM-2 — ôn đúng lúc, nhớ lâu hơn.',
          accent: AppColors.success,
        ),
        _OnboardingPage(
          icon: Icons.record_voice_over_rounded,
          title: 'Luyện 4 kỹ năng + Phát âm AI',
          desc:
              'Nghe, nói, đọc, viết và chấm phát âm bằng AI. Theo dõi kỹ năng nào cần cải thiện.',
          accent: AppColors.tertiary,
        ),
      ];

  bool get _isLast => _index == _pages.length - 1;
  Color get _accent => _pages[_index].accent;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kSeenOnboardingKey, true);
    Get.offAllNamed(AppRoutes.welcome);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Khối màu nền mờ phía sau, đổi màu theo trang để sinh động.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            top: -120,
            right: _index.isEven ? -100 : -160,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            bottom: 40,
            left: _index.isEven ? -140 : -90,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // "Bỏ qua" — vẫn đánh dấu đã xem để không hiện lại.
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Bỏ qua',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _PageView(
                      page: pages[i],
                      active: i == _index,
                    ),
                  ),
                ),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? _accent
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                  child: AppButton(
                    label: _isLast ? 'Bắt đầu' : 'Tiếp tục',
                    isTranslate: false,
                    onPressed: _next,
                    trailing: Icon(
                      _isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page, required this.active});

  final _OnboardingPage page;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon phóng to mượt khi trang được kích hoạt.
          AnimatedScale(
            scale: active ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: _IconBadge(icon: page.icon, accent: page.accent),
          ),
          AppGap.h40,
          AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.25,
                  ),
                ),
                AppGap.h14,
                Text(
                  page.desc,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vòng tròn icon 2 lớp (halo mờ + lõi đặc) tạo chiều sâu.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      height: 152,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, size: 56, color: accent),
        ),
      ),
    );
  }
}
