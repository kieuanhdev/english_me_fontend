import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:englishme/theme/app_theme.dart';

/// Mưa giấy confetti thuần Flutter (không thêm package). Dùng [ConfettiOverlay.burst]
/// để bắn 1 lần phủ toàn màn, hoặc nhúng widget [ConfettiOverlay] vào trong 1
/// dialog/celebration.
///
/// Hiệu ứng: các mảnh giấy rơi từ trên xuống, xoay nhẹ, mờ dần ở cuối. Tự huỷ
/// sau khi animation xong.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    this.pieceCount = 80,
    this.duration = const Duration(milliseconds: 2200),
    this.onDone,
  });

  /// Số mảnh confetti.
  final int pieceCount;

  /// Thời lượng rơi.
  final Duration duration;

  /// Gọi khi animation kết thúc (vd để gỡ overlay).
  final VoidCallback? onDone;

  /// Bắn 1 lần confetti phủ toàn màn qua [Overlay] gốc. Tự chèn và tự gỡ.
  /// An toàn gọi sau điều hướng (dùng addPostFrameCallback ở caller nếu cần).
  static void burst(
    BuildContext context, {
    int pieceCount = 90,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: ConfettiOverlay(
          pieceCount: pieceCount,
          duration: duration,
          onDone: () => entry.remove(),
        ),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    final colors = <Color>[
      AppColors.primary,
      AppColors.tertiary,
      AppColors.success,
      AppColors.statFgWarm,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
    ];
    _pieces = List.generate(widget.pieceCount, (i) {
      return _Piece(
        startX: rnd.nextDouble(),
        // Bắt đầu lệch lên trên 1 chút để rơi mượt.
        startY: -0.1 - rnd.nextDouble() * 0.3,
        horizontalDrift: (rnd.nextDouble() - 0.5) * 0.4,
        rotationSpeed: (rnd.nextDouble() - 0.5) * 8,
        size: 6 + rnd.nextDouble() * 8,
        color: colors[rnd.nextInt(colors.length)],
        delay: rnd.nextDouble() * 0.25,
        isRect: rnd.nextBool(),
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone?.call();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Piece {
  _Piece({
    required this.startX,
    required this.startY,
    required this.horizontalDrift,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.delay,
    required this.isRect,
  });

  final double startX; // 0..1 (tỉ lệ chiều rộng)
  final double startY; // tỉ lệ chiều cao (có thể âm)
  final double horizontalDrift; // lệch ngang khi rơi
  final double rotationSpeed;
  final double size;
  final Color color;
  final double delay; // 0..1, hoãn bắt đầu
  final bool isRect;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_Piece> pieces;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      // Mỗi mảnh có delay riêng → tiến trình hiệu dụng của nó.
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      // Rơi xuống quá đáy (1.2) để mảnh đi hẳn ra ngoài.
      final y = (p.startY + t * 1.3) * size.height;
      final x = (p.startX + p.horizontalDrift * t) * size.width;
      // Mờ dần ở 25% cuối.
      final opacity = t > 0.75 ? (1 - (t - 0.75) / 0.25) : 1.0;

      paint.color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * t);
      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
