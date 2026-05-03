import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class FlashcardWordOfDay extends GetView<FlashcardController> {
  const FlashcardWordOfDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative background icon
            Positioned(
              right: -8,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.auto_stories_rounded,
                size: 110,
                color: AppColors.onSurface.withValues(alpha: 0.06),
              ),
            ),
            // Glow blob
            Positioned(
              right: -40,
              bottom: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryFixedDim.withValues(alpha: 0.18),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WORD OF THE DAY',
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() => Text(
                  controller.wordOfDay.value,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 34,
                    color: AppColors.primary,
                  ),
                )),
                const SizedBox(height: 6),
                Obx(() => Text(
                  controller.wordDefinition.value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                )),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: controller.onPracticeWordOfDay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Practice Now',
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 14,
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
