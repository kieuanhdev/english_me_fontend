import 'package:flutter/material.dart';

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
    this.onBack,
    this.onSearch,
    this.onSettings,
    this.horizontalPadding = 20,
  });

  final String? title;
  final String? subtitle;
  final bool showSearch;
  final bool showBack;
  final bool showSettings;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
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
      onBack: onBack,
      onSearch: onSearch,
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
    this.showSettings = false,
    this.onBack,
    this.onSearch,
    this.onSettings,
    this.horizontalPadding = 20,
  });

  final String? title;
  final String? subtitle;
  final bool showBack;
  final bool showSearch;
  final bool showSettings;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
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
