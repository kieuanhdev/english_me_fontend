import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeHeroSection extends GetView<HomeController> {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hôm nay của bạn\nthế nào?',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 26,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                AppGap.h6,
                Obx(() => Text(
                  'Bạn đã đạt ${(controller.xpProgress * 100).toInt()}% mục tiêu hôm nay. Tiếp tục nhé!',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                )),
              ],
            ),
          ),
          AppGap.w16,
          Obx(() => _XpRing(
            current: controller.currentXp.value,
            target: controller.targetXp.value,
            progress: controller.xpProgress,
          )),
        ],
      ),
    );
  }
}

class _XpRing extends StatelessWidget {
  const _XpRing({
    required this.current,
    required this.target,
    required this.progress,
  });

  final int current;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _RingPainter(progress: progress),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 24,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                Text(
                  '/ $target XP',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 8.0;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.secondaryContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Indicator
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
