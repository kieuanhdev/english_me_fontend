import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/data/models/desk_model.dart';
import 'package:englishme/modules/flashcard/controllers/flashcard_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class FlashcardDeckList extends GetView<FlashcardController> {
  const FlashcardDeckList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Bộ thẻ',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAll,
                child: Text(
                  'Xem tất cả',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppGap.h16,
        Obx(() {
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.errorMessage.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                  AppGap.h12,
                  GestureDetector(
                    onTap: controller.loadDesks,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Thử lại',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final desk in controller.desks) ...[
                  _DeckCard(
                    desk: desk,
                    onStartStudy: () => controller.onStartStudy(desk),
                    onEdit: () => controller.onEditDeck(desk),
                    onDelete: () => controller.onDeleteDeck(desk),
                  ),
                  AppGap.h14,
                ],
                _CreateDeckTile(onTap: controller.onCreateDeck),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Deck Card ────────────────────────────────────────────────────────────────

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.desk,
    required this.onStartStudy,
    required this.onEdit,
    required this.onDelete,
  });

  final DeskModel desk;
  final VoidCallback onStartStudy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Map CEFR → màu sắc
  static Color _bgColor(String cefr) => switch (cefr.toUpperCase()) {
        'A1' || 'A2' => const Color(0xFFDEF7EC),
        'B1' || 'B2' => const Color(0xFFDEE0FF),
        'C1' || 'C2' => const Color(0xFFFFDCBE),
        _ => const Color(0xFFEEEEEE),
      };

  static Color _fgColor(String cefr) => switch (cefr.toUpperCase()) {
        'A1' || 'A2' => const Color(0xFF1B5E20),
        'B1' || 'B2' => const Color(0xFF24389C),
        'C1' || 'C2' => const Color(0xFF643900),
        _ => const Color(0xFF454652),
      };

  static IconData _icon(String cefr) => switch (cefr.toUpperCase()) {
        'A1' || 'A2' => Icons.eco_rounded,
        'B1' || 'B2' => Icons.school_rounded,
        'C1' || 'C2' => Icons.military_tech_rounded,
        _ => Icons.style_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(desk.cefrLevel);
    final fg = _fgColor(desk.cefrLevel);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + CEFR badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
                  child: Icon(_icon(desk.cefrLevel), color: fg, size: 26),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    desk.cefrLevel,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: fg,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 22, color: AppColors.iconMuted),
                  padding: EdgeInsets.zero,
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Sửa bộ thẻ')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Xóa bộ thẻ',
                        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppGap.h14,
            // Title
            Text(desk.title, style: AppTypography.displayLarge.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            // Card count
            Text(
              '${desk.flashcardCount} từ vựng',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            AppGap.h16,
            // Start Study button
            GestureDetector(
              onTap: onStartStudy,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Bắt đầu học',
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
      ),
    );
  }
}

// ─── Create Deck Tile ─────────────────────────────────────────────────────────

class _CreateDeckTile extends StatelessWidget {
  const _CreateDeckTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant, width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 28, color: AppColors.iconMuted),
            ),
            AppGap.h12,
            Text(
              'Tạo bộ thẻ mới',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm từ vựng tùy chỉnh',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
