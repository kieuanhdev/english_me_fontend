import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/profile/models/profile_model.dart';
import 'package:englishme/theme/app_theme.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key, required this.user});
  final ProfileUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        children: [
          _Avatar(photoUrl: user.photoUrl, name: user.displayName),
          AppGap.h14,
          Obx(() {
            if (controller.isEditingName.value) {
              return _NameEditor(controller: controller);
            }
            return _NameDisplay(user: user, onEdit: controller.startEditName);
          }),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 12,
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.75),
            ),
          ),
          AppGap.h16,
          _CefrBadge(level: user.cefrLevel, label: controller.cefrLabel),
          AppGap.h16,
          _StatsRow(user: user),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});
  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.onPrimaryFixed.withValues(alpha: 0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Fallback(name: name),
              )
            : _Fallback(name: name),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.onPrimaryFixed.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.displayLarge.copyWith(
          fontSize: 36,
          color: AppColors.onPrimaryFixed,
        ),
      ),
    );
  }
}

class _NameDisplay extends StatelessWidget {
  const _NameDisplay({required this.user, required this.onEdit});
  final ProfileUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.displayName,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 20,
              color: AppColors.onPrimaryFixed,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.edit_rounded, color: AppColors.onPrimaryFixed.withValues(alpha: 0.7), size: 16),
        ],
      ),
    );
  }
}

class _NameEditor extends StatelessWidget {
  const _NameEditor({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 180,
          height: 36,
          child: TextField(
            controller: controller.nameController,
            autofocus: true,
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 18,
              color: AppColors.onPrimaryFixed,
            ),
            cursorColor: AppColors.onPrimaryFixed,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.onPrimaryFixed.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.onPrimaryFixed),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() => controller.isSavingName.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.onPrimaryFixed, strokeWidth: 2),
              )
            : GestureDetector(
                onTap: controller.saveDisplayName,
                child: Icon(Icons.check_circle_rounded, color: AppColors.onPrimaryFixed, size: 28),
              )),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: controller.cancelEditName,
          child: Icon(Icons.cancel_rounded, color: AppColors.onPrimaryFixed.withValues(alpha: 0.7), size: 28),
        ),
      ],
    );
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level, required this.label});
  final String level;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.onPrimaryFixed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.onPrimaryFixed.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.onPrimaryFixed,
            ),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 12, color: AppColors.onPrimaryFixed.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.user});
  final ProfileUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: '${user.totalXp}', label: 'Tổng XP', icon: Icons.bolt_rounded),
        _Divider(),
        _StatItem(value: '${user.currentStreak}', label: 'Streak hiện tại', icon: Icons.local_fire_department_rounded),
        _Divider(),
        _StatItem(value: '${user.longestStreak}', label: 'Streak cao nhất', icon: Icons.emoji_events_rounded),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.onPrimaryFixed.withValues(alpha: 0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.onPrimaryFixed.withValues(alpha: 0.9), size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 18,
                color: AppColors.onPrimaryFixed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelXSmall.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimaryFixed.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
