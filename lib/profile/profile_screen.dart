import 'package:flutter/material.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/locale_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/theme/theme_controller.dart';
import 'package:englishme/welcome/welcome_screen.dart';
import 'package:get/get.dart';

const _kSectionTitleColor = Color(0xFF51577f);
const _kSecondaryBrand = Color(0xFF565c84);

/// Profile / Cài đặt — theo [stitch_englishme_prd (11)] (`settings_screen`, `interface_language_settings`).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _aiTipsWeekly = true;

  static const Color _primaryFixed = Color(0xFFdee0ff);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AppBottomNav(initialIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileTopBar(onBack: () => Get.offAllNamed(AppRoutes.home)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeroCard(),
                    AppGap.h20,
                    _SettingsSection(
                      title: 'Tài khoản',
                      children: [
                        _SettingsNavTile(
                          icon: Icons.person_rounded,
                          iconBackground: _primaryFixed,
                          title: 'Thông tin cá nhân',
                          onTap: () {},
                        ),
                        const SizedBox(height: 4),
                        _SettingsNavTile(
                          icon: Icons.lock_rounded,
                          iconBackground: _primaryFixed,
                          title: 'Đổi mật khẩu',
                          onTap: () {},
                        ),
                      ],
                    ),
                    AppGap.h12,
                    _SettingsSection(
                      title: 'Học tập',
                      children: [
                        _SettingsNavTile(
                          icon: Icons.track_changes_rounded,
                          iconBackground: AppColors.secondaryContainer,
                          title: 'Mục tiêu hàng ngày',
                          trailingBadge: '15 Phút',
                          onTap: () {},
                        ),
                        const SizedBox(height: 4),
                        _SettingsNavTile(
                          icon: Icons.translate_rounded,
                          iconBackground: AppColors.secondaryContainer,
                          title: 'Ngôn ngữ giao diện',
                          onTap: () {},
                        ),
                      ],
                    ),
                    AppGap.h12,
                    _SettingsSection(
                      title: 'Giao diện',
                      children: [_AppearanceBlock()],
                    ),
                    AppGap.h12,
                    Text(
                      'Ngôn ngữ',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppGap.h14,
                    _LanguagePickerBlock(),
                    AppGap.h24,
                    _SettingsSection(
                      title: 'Thông báo',
                      children: [
                        _SettingsNavTile(
                          icon: Icons.notifications_rounded,
                          iconBackground: AppColors.tertiary.withValues(alpha: 0.25),
                          iconColor: AppColors.tertiary,
                          title: 'Chế độ nhắc nhở',
                          onTap: () {},
                        ),
                        const SizedBox(height: 4),
                        _SettingsSwitchTile(
                          icon: Icons.smart_toy_rounded,
                          iconBackground: AppColors.tertiary.withValues(alpha: 0.25),
                          iconColor: AppColors.tertiary,
                          title: 'AI Tips hàng tuần',
                          value: _aiTipsWeekly,
                          onChanged: (v) => setState(() => _aiTipsWeekly = v),
                        ),
                      ],
                    ),
                    AppGap.h12,
                    _SettingsSection(
                      title: 'Hỗ trợ',
                      children: [
                        _SettingsNavTile(
                          icon: Icons.help_center_rounded,
                          iconBackground: AppColors.surfaceContainerHigh,
                          iconColor: AppColors.iconMuted,
                          title: 'Trung tâm trợ giúp',
                          onTap: () {},
                        ),
                        const SizedBox(height: 4),
                        _SettingsNavTile(
                          icon: Icons.contact_support_rounded,
                          iconBackground: AppColors.surfaceContainerHigh,
                          iconColor: AppColors.iconMuted,
                          title: 'Liên hệ hỗ trợ',
                          onTap: () {},
                        ),
                      ],
                    ),
                    AppGap.h24,
                    _PromoCard(),
                    AppGap.h24,
                    Material(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: Text(
                              'Đăng xuất',
                              style: AppTypography.headlineMedium.copyWith(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppGap.h16,
                    Center(
                      child: Text(
                        'EnglishMe v1.0.0',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 11,
                          color: AppColors.iconMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Text(
              'Profile',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () {},
                icon: const Icon(Icons.settings_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 96,
                  height: 96,
                  color: const Color(0xFFdee0ff),
                  child: Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onSurface.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          AppGap.w16,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nguyễn Kiều Anh',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  AppGap.h6,
                  Text(
                    'Gold League • Chuỗi 124 ngày',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kSecondaryBrand,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                color: _kSectionTitleColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.iconBackground,
    required this.title,
    this.iconColor,
    this.trailingBadge,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color? iconColor;
  final String title;
  final String? trailingBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixedDim.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    trailingBadge!,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                AppGap.w8,
              ],
              Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.55),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AppearanceBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 10),
            child: Text(
              'CHẾ ĐỘ TỐI',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Obx(() {
            final ThemeController t = Get.find<ThemeController>();
            final mode = t.themeModeRx.value;
            return Row(
              children: [
                Expanded(
                  child: _ThemeModeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'Sáng',
                    selected: mode == ThemeMode.light,
                    onTap: () => t.setThemeMode(ThemeMode.light),
                  ),
                ),
                AppGap.w10,
                Expanded(
                  child: _ThemeModeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'Tối',
                    selected: mode == ThemeMode.dark,
                    onTap: () => t.setThemeMode(ThemeMode.dark),
                  ),
                ),
                AppGap.w10,
                Expanded(
                  child: _ThemeModeOption(
                    icon: Icons.brightness_auto_rounded,
                    label: 'Hệ thống',
                    selected: mode == ThemeMode.system,
                    onTap: () => t.setThemeMode(ThemeMode.system),
                  ),
                ),
              ],
            );
          }),
          AppGap.h20,
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 10),
            child: Text(
              'MÀU CHỦ ĐẠO',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _AccentSwatch(color: Color(0xFF24389c), selected: true),
                _AccentSwatch(color: Color(0xFF854d00), selected: false),
                _AccentSwatch(color: Color(0xFF2563EB), selected: false),
                _AccentSwatch(color: Color(0xFF059669), selected: false),
                _AccentSwatch(color: Color(0xFF7C3AED), selected: false),
                _AccentSwatch(color: Color(0xFFF43F5E), selected: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : AppColors.iconMuted,
              ),
              AppGap.h8,
              Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.onSurface : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
            : null,
      ),
    );
  }
}

class _LanguagePickerBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppLocaleController c = Get.find<AppLocaleController>();
      final vi = c.isVietnamese;
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _LanguageTile(
              title: 'Tiếng Việt',
              subtitle: 'Ngôn ngữ ứng dụng chính',
              selected: vi,
              onTap: () => c.setLocale(const Locale('vi', 'VN')),
            ),
                    const SizedBox(height: 4),
            _LanguageTile(
              title: 'English',
              subtitle: 'Application language',
              selected: !vi,
              onTap: () => c.setLocale(const Locale('en', 'US')),
            ),
          ],
        ),
      );
    });
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceContainerLowest : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                ),
                child: Icon(Icons.language_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primary : AppColors.iconMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Học tập hiệu quả hơn',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              AppGap.h10,
              Text(
                'Tùy chỉnh không gian học tập mang đậm dấu ấn cá nhân của riêng bạn.',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 15,
                  height: 1.35,
                  color: const Color(0xFFcacfff),
                ),
              ),
              AppGap.h16,
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Lưu thay đổi',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: -30,
            bottom: -40,
            child: Icon(
              Icons.blur_on_rounded,
              size: 120,
              color: AppColors.tertiary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
