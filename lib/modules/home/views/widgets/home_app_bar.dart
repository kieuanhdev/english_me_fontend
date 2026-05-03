import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeAppBar extends GetView<HomeController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer,
              border: Border.all(color: AppColors.outlineVariant, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text(
                controller.greetingLabel.value,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              )),
              Text(
                'EnglishMe',
                style: AppTypography.brand,
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
