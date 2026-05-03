import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeWordOfDay extends GetView<HomeController> {
  const HomeWordOfDay({super.key});

  // Màu nền: tertiary-fixed ≈ cam nhạt ấm
  static const Color _bgColor = Color(0xFFFFEDD5);
  static const Color _wordColor = Color(0xFF854D00);
  static const Color _ipaColor = Color(0xFF693C00);
  static const Color _badgeBg = Color(0xFF2C1600);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative background icon
            Positioned(
              right: -16,
              bottom: -16,
              child: Icon(
                Icons.menu_book_rounded,
                size: 120,
                color: _wordColor.withValues(alpha: 0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TỪ VỰNG MỖI NGÀY',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppGap.h12,
                // Word + IPA
                Obx(() => Text(
                  controller.wordOfDay.value,
                  style: AppTypography.displayAccent.copyWith(
                    fontSize: 38,
                    color: _wordColor,
                    height: 1.1,
                  ),
                )),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.wordIpa.value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: _ipaColor,
                  ),
                )),
                AppGap.h14,
                // Definitions
                Obx(() => Text(
                  controller.wordDefinitionEn.value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                )),
                AppGap.h6,
                Obx(() => Text(
                  controller.wordDefinitionVi.value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _ipaColor,
                    height: 1.4,
                  ),
                )),
                AppGap.h16,
                // Listen button
                GestureDetector(
                  onTap: controller.onListenWordOfDay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Nghe phát âm',
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
