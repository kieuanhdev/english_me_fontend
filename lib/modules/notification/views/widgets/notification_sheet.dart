import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/notification/controllers/notification_controller.dart';
import 'package:englishme/modules/notification/models/notification_model.dart';
import 'package:englishme/theme/app_theme.dart';

/// Bottom sheet thông báo — data-driven, thay cho sheet hardcode cũ.
class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.ensureRegistered();
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
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
                Obx(() {
                  if (controller.unreadCount.value == 0) {
                    return const SizedBox.shrink();
                  }
                  return TextButton(
                    onPressed: controller.markAllRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Đánh dấu đã đọc',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(Icons.close_rounded, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Obx(() {
                switch (controller.loadState.value) {
                  case NotificationLoadState.loading:
                  case NotificationLoadState.idle:
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  case NotificationLoadState.error:
                    return _ErrorState(onRetry: controller.loadAll);
                  case NotificationLoadState.success:
                    final items = controller.items;
                    if (items.isEmpty) return const _EmptyState();
                    return ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _NotificationItem(
                        notification: items[i],
                        onTap: () => controller.onTapNotification(items[i]),
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 44,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            'Chưa có thông báo nào.',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            'Không tải được thông báo.',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Thử lại',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(notification.type);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(visual.icon, color: visual.color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual(this.icon, this.color);
  final IconData icon;
  final Color color;
}

_NotificationVisual _visualFor(String type) {
  switch (type) {
    case 'REVIEW_DUE':
      return _NotificationVisual(
        Icons.local_fire_department_rounded,
        AppColors.tertiary,
      );
    case 'STREAK_RISK':
      return _NotificationVisual(
        Icons.local_fire_department_rounded,
        AppColors.tertiary,
      );
    case 'LESSON_UNLOCKED':
      return _NotificationVisual(Icons.school_rounded, AppColors.primary);
    case 'PLACEMENT_SUGGESTION':
      return _NotificationVisual(
        Icons.assignment_turned_in_rounded,
        AppColors.success,
      );
    case 'SYSTEM':
    default:
      return _NotificationVisual(
        Icons.notifications_active_rounded,
        AppColors.primary,
      );
  }
}
