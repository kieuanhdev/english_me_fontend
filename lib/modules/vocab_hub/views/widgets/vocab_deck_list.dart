import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_deck_controller.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabDeckList extends GetView<VocabDeckController> {
  const VocabDeckList({
    super.key,
    required this.decksSelector,
    required this.emptyMessage,
    this.emptyIcon = Icons.style_outlined,
  });

  /// Hàm lọc danh sách desk từ controller (vd systemDecks / myDecks).
  /// Đọc bên trong Obx nên phải tham chiếu `controller.decks` để rebuild đúng.
  final List<VocabDeck> Function(VocabDeckController c) decksSelector;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.danger,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppGap.h12,
                  GestureDetector(
                    onTap: controller.loadDecks,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        T.actionRetry.tr,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onPrimaryFixed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // Lọc danh sách theo selector (systemDecks / myDecks). Đọc controller.decks
          // bên trong Obx này để rebuild khi danh sách thay đổi.
          final list = decksSelector(controller);
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              child: Column(
                children: [
                  Icon(emptyIcon, size: 44, color: AppColors.iconMuted),
                  AppGap.h12,
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          // Nhóm các bộ thẻ theo CEFR. Cấp của user lên đầu, rồi các cấp thấp
          // hơn xếp giảm dần (vd user A2: A2 → A1).
          final groups = _groupByCefr(list, controller.userLevel.value);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in groups.entries) ...[
                  _GroupHeader(level: entry.key, count: entry.value.length),
                  AppGap.h10,
                  for (final deck in entry.value) ...[
                    _DeckCard(
                      deck: deck,
                      onStartStudy: () => controller.onStartStudy(deck),
                      onEdit: () => controller.onEditDeck(deck),
                      onDelete: () => controller.onDeleteDeck(deck),
                    ),
                    AppGap.h14,
                  ],
                  AppGap.h8,
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Gom desk theo CEFR. Thứ tự nhóm: cấp của user lên ĐẦU, rồi các cấp
  /// THẤP hơn xếp giảm dần (vd user A2 → A2, A1). Cấp cao hơn cấp user thường
  /// đã bị controller lọc bỏ; nếu lọt vào (userLevel rỗng) thì xếp tăng dần sau
  /// các cấp ≤ user. Nhóm CEFR lạ luôn ở cuối. Trong mỗi nhóm: bộ hệ thống
  /// trước, rồi theo sortOrder.
  static Map<String, List<VocabDeck>> _groupByCefr(
    List<VocabDeck> decks,
    String userLevel,
  ) {
    const order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final userIdx = order.indexOf(userLevel.toUpperCase());
    final map = <String, List<VocabDeck>>{};
    for (final d in decks) {
      map.putIfAbsent(d.cefrLevel.toUpperCase(), () => []).add(d);
    }
    for (final list in map.values) {
      list.sort((a, b) {
        if (a.isSystem != b.isSystem) return a.isSystem ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    }
    // Khoá sắp xếp: cấp ≤ user xếp giảm dần (gần cấp user nhất lên trước),
    // cấp > user (chỉ xảy ra khi không lọc) xếp tăng dần phía sau, nhóm lạ cuối.
    int rank(String level) {
      final idx = order.indexOf(level);
      if (idx == -1) return 1000; // nhóm lạ → cuối
      if (userIdx == -1) return idx; // chưa rõ cấp user → A1→C2 như cũ
      if (idx <= userIdx) return userIdx - idx; // ≤ user: gần user lên trước
      return 100 + idx; // > user: sau cùng nhóm hợp lệ, tăng dần
    }

    final sortedKeys = map.keys.toList()
      ..sort((a, b) {
        final ra = rank(a), rb = rank(b);
        if (ra != rb) return ra.compareTo(rb);
        return a.compareTo(b);
      });
    return {for (final k in sortedKeys) k: map[k]!};
  }
}

// ─── Group Header (theo CEFR) ───────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.level, required this.count});
  final String level;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        T.deckGroupTitle.trParams({'level': level, 'count': '$count'}),
        style: AppTypography.headlineMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Deck Card ────────────────────────────────────────────────────────────────

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.deck,
    required this.onStartStudy,
    required this.onEdit,
    required this.onDelete,
  });

  final VocabDeck deck;
  final VoidCallback onStartStudy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Color _bgColor(String cefr) => switch (cefr.toUpperCase()) {
    'A1' || 'A2' => AppColors.levelABg,
    'B1' || 'B2' => AppColors.levelBBg,
    'C1' || 'C2' => AppColors.levelCBg,
    _ => AppColors.surfaceContainerLow,
  };

  static Color _fgColor(String cefr) => switch (cefr.toUpperCase()) {
    'A1' || 'A2' => AppColors.levelAFg,
    'B1' || 'B2' => AppColors.levelBFg,
    'C1' || 'C2' => AppColors.levelCFg,
    _ => AppColors.textSecondary,
  };

  static IconData _icon(String cefr) => switch (cefr.toUpperCase()) {
    'A1' || 'A2' => Icons.eco_rounded,
    'B1' || 'B2' => Icons.school_rounded,
    'C1' || 'C2' => Icons.military_tech_rounded,
    _ => Icons.style_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(deck.cefrLevel);
    final fg = _fgColor(deck.cefrLevel);
    // Đồng bộ với _TopicCard: layout ngang, border + shadow nhẹ, bấm cả thẻ để học.
    return GestureDetector(
      onTap: onStartStudy,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.vocabCardMinHeight,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(_icon(deck.cefrLevel), color: fg, size: 26),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        label: T.labelVocabCount.tr.replaceAll(
                          '{count}',
                          '${deck.flashcardCount}',
                        ),
                        icon: Icons.style_rounded,
                        color: AppColors.primary,
                      ),
                      _Chip(
                        label: deck.cefrLevel,
                        icon: Icons.bar_chart_rounded,
                        color: fg,
                      ),
                      // Bộ hệ thống: gắn nhãn "Hệ thống" thay cho menu sửa/xoá.
                      if (deck.isSystem)
                        _Chip(
                          label: T.deckBadgeSystem.tr,
                          icon: Icons.verified_rounded,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                  _DeckProgress(deckId: deck.id),
                ],
              ),
            ),
            // Desk hệ thống không cho sửa/xoá (backend lọc theo owner) → chỉ mũi tên học.
            if (deck.isSystem)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.iconMuted,
              )
            else
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppColors.iconMuted,
                ),
                padding: EdgeInsets.zero,
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(T.flashcardEditDeck.tr),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      T.flashcardDeleteDeck.tr,
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
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

// ─── Mini tiến độ học (đọc progressByDeck) ──────────────────────────────────────

/// Thanh tiến độ + dòng số liệu (đến hạn · mới · đã thuộc) cho 1 bộ thẻ.
/// Dữ liệu từ `controller.progressByDeck` — tải nền sau danh sách, nên bọc Obx.
/// Ẩn khi chưa có dữ liệu hoặc bộ rỗng (tránh hiện thanh 0% gây nhiễu).
class _DeckProgress extends GetView<VocabDeckController> {
  const _DeckProgress({required this.deckId});
  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.progressByDeck[deckId];
      if (p == null || p.total <= 0) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                height: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: AppColors.surfaceContainerLow),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: p.masteryRatio.clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: ColoredBox(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (p.hasDue) ...[
                  _statDot(AppColors.tertiary),
                  Text(
                    T.deckDueCount.trParams({'count': '${p.due}'}),
                    style: _statStyle(AppColors.tertiary, bold: true),
                  ),
                  AppGap.w12,
                ],
                if (p.fresh > 0) ...[
                  _statDot(AppColors.primary),
                  Text(
                    T.deckNewCardsCount.trParams({'count': '${p.fresh}'}),
                    style: _statStyle(AppColors.textSecondary),
                  ),
                  AppGap.w12,
                ],
                _statDot(AppColors.success),
                Text(
                  T.deckMasteredCardsCount.trParams({'count': '${p.mastered}'}),
                  style: _statStyle(AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statDot(Color color) => Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );

  TextStyle _statStyle(Color color, {bool bold = false}) =>
      AppTypography.labelXSmall.copyWith(
        fontSize: 11,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        color: color,
      );
}

// ─── Chip (đồng bộ với _TopicCard) ──────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelXSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
