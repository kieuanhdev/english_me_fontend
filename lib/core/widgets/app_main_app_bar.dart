import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/core/widgets/app_settings_icon_button.dart';
import 'package:englishme/theme/app_theme.dart';

class AppMainAppBar extends StatelessWidget {
  const AppMainAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showSearch = false,
    this.showBack = false,
    this.showSettings = true,
    this.showNotification = true,
    this.onBack,
    this.onSearch,
    this.onNotification,
    this.onSettings,
    this.horizontalPadding = 20,
  });

  final String? title;
  final String? subtitle;
  final bool showSearch;
  final bool showBack;
  final bool showSettings;
  final bool showNotification;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onNotification;
  final VoidCallback? onSettings;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: title,
      subtitle: subtitle,
      showBack: showBack,
      showSearch: showSearch,
      showSettings: showSettings,
      showNotification: showNotification,
      onBack: onBack,
      onSearch: onSearch,
      onNotification: onNotification,
      onSettings: onSettings,
      horizontalPadding: horizontalPadding,
    );
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.showSearch = false,
    this.showNotification = false,
    this.showSettings = false,
    this.onBack,
    this.onSearch,
    this.onNotification,
    this.onSettings,
    this.horizontalPadding = 20,
  });

  final String? title;
  final String? subtitle;
  final bool showBack;
  final bool showSearch;
  final bool showNotification;
  final bool showSettings;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onNotification;
  final VoidCallback? onSettings;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          if (showBack) ...[
            AppBackButton(onPressed: onBack ?? () => Navigator.maybePop(context)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: _HeaderTitle(
              title: hasTitle ? title! : 'EnglishMe',
              subtitle: subtitle,
              isBrand: !hasTitle,
            ),
          ),
          if (showSearch) ...[
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.search_rounded,
              color: AppColors.textSecondary,
              onTap: onSearch,
            ),
          ],
          if (showNotification) ...[
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.notifications_outlined,
              color: AppColors.primary,
              onTap: onNotification ?? _showNotifications,
            ),
          ],
          if (showSettings) ...[
            const SizedBox(width: 8),
            if (onSettings == null)
              const AppSettingsIconButton()
            else
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                color: AppColors.primary,
                onTap: onSettings,
              ),
          ],
        ],
      ),
    );
  }

  void _showNotifications() {
    Get.bottomSheet<void>(
      const _NotificationSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.title,
    required this.isBrand,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool isBrand;

  @override
  Widget build(BuildContext context) {
    final titleStyle = isBrand
        ? AppTypography.brand
        : AppTypography.displayLarge.copyWith(
            fontSize: 20,
            color: AppColors.primary,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          Text(
            subtitle!,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
        ],
        Text(
          title,
          style: titleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _NotificationSheet extends StatelessWidget {
  const _NotificationSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralShadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Thông báo',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(Icons.close_rounded, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _NotificationItem(
              icon: Icons.local_fire_department_rounded,
              title: 'Duy trì streak hôm nay',
              message: 'Hoàn thành một bài học để giữ chuỗi học tập.',
              color: AppColors.tertiary,
            ),
            const SizedBox(height: 10),
            _NotificationItem(
              icon: Icons.school_rounded,
              title: 'Gợi ý học tiếp',
              message: 'Bạn có thể tiếp tục lộ trình hoặc ôn phần bổ trợ.',
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _NotificationItem(
              icon: Icons.assignment_turned_in_rounded,
              title: 'Kiểm tra trình độ',
              message: 'Khi hoàn thành level, app sẽ gợi ý bài kiểm tra nâng cấp.',
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
