import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/theme/app_theme.dart';

/// Các mảnh UI dùng chung giữa thẻ từ vựng (topic) và thẻ học SM-2 (flashcard).
///
/// 3 màn — danh sách từ theo chủ đề, mặt trước & mặt sau phiên học SM-2 — có
/// layout tổng thể khác nhau, nhưng lặp lại đúng 3 mảnh con này. Tách ra đây để
/// dùng lại mà không gộp 3 layout thành một "god widget".

/// Nút loa tròn phát âm một từ.
class WordSpeakButton extends StatelessWidget {
  const WordSpeakButton({
    super.key,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.color,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;

  /// Màu icon; mặc định [AppColors.primary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
        child: Icon(Icons.volume_up_rounded, color: fg, size: iconSize),
      ),
    );
  }
}

/// Badge loại từ (part of speech).
///
/// [big] = true cho biến thể pill nổi bật (mặt sau phiên học); mặc định là chip
/// nhỏ dùng trong danh sách từ.
class WordPosBadge extends StatelessWidget {
  const WordPosBadge({super.key, required this.text, this.big = false});

  final String text;
  final bool big;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    if (big) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.levelCBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          text.toUpperCase(),
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.levelCFg,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: AppTypography.bodyLarge.copyWith(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Khối ví dụ: câu tiếng Anh (highlight từ khóa) + bản dịch tùy chọn.
class WordExampleBox extends StatelessWidget {
  const WordExampleBox({
    super.key,
    required this.sentence,
    this.translation = '',
    this.highlightWord = '',
  });

  final String sentence;
  final String translation;

  /// Từ cần tô đậm trong câu (thường là từ đang học). Bỏ trống nếu không cần.
  final String highlightWord;

  @override
  Widget build(BuildContext context) {
    if (sentence.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(
          left: BorderSide(color: AppColors.primaryContainer, width: 3.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.6,
                color: AppColors.onSurface,
              ),
              children: _buildSpans(sentence, highlightWord),
            ),
          ),
          if (translation.isNotEmpty) ...[
            AppGap.h10,
            Text(
              translation,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<TextSpan> _buildSpans(String sentence, String word) {
    if (word.isEmpty) return [TextSpan(text: '"$sentence"')];
    final lower = sentence.toLowerCase();
    final idx = lower.indexOf(word.toLowerCase());
    if (idx == -1) return [TextSpan(text: '"$sentence"')];
    return [
      TextSpan(text: '"${sentence.substring(0, idx)}'),
      TextSpan(
        text: sentence.substring(idx, idx + word.length),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.normal,
        ),
      ),
      TextSpan(text: '${sentence.substring(idx + word.length)}"'),
    ];
  }
}
