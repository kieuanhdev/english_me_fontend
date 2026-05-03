import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

/// AppBar dùng chung cho các màn hình chính (Home, Flashcards, ...).
///
/// - [title]: tên màn hình hiển thị bên phải avatar. Nếu null, hiện brand "EnglishMe" + [subtitle].
/// - [subtitle]: dòng nhỏ phía trên brand (vd: lời chào). Chỉ hiện khi [title] == null.
/// - [showSearch]: hiện icon tìm kiếm trước chuông.
/// - [onSearch] / [onNotification]: callback tương ứng.
class AppMainAppBar extends StatelessWidget {
  const AppMainAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showSearch = false,
    this.onSearch,
    this.onNotification,
  });

  final String? title;
  final String? subtitle;
  final bool showSearch;
  final VoidCallback? onSearch;
  final VoidCallback? onNotification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer,
              border: Border.all(color: AppColors.outlineVariant, width: 2),
            ),
            child: const Icon(Icons.person_rounded, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          // Title area
          if (title != null)
            Text(
              title!,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 20,
                color: AppColors.primary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text('EnglishMe', style: AppTypography.brand),
              ],
            ),
          const Spacer(),
          // Search (tuỳ chọn)
          if (showSearch) ...[
            _IconButton(
              icon: Icons.search_rounded,
              color: AppColors.textSecondary,
              onTap: onSearch,
            ),
            const SizedBox(width: 8),
          ],
          // Notification
          _IconButton(
            icon: Icons.notifications_outlined,
            color: AppColors.primary,
            onTap: onNotification,
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.color, this.onTap});

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
          boxShadow: const [
            BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
