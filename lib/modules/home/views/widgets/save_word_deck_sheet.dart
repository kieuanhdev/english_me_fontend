import 'package:englishme/core/utils/app_notify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_deck_model.dart';
import 'package:englishme/theme/app_theme.dart';

/// Bottom sheet chọn bộ thẻ để lưu "từ vựng hằng ngày". Chỉ liệt kê bộ thẻ của
/// user (không phải bộ hệ thống). Nếu chưa có bộ nào → cho tạo nhanh theo CEFR.
class SaveWordDeckSheet extends StatefulWidget {
  const SaveWordDeckSheet({
    super.key,
    required this.word,
    required this.suggestedCefr,
  });

  final String word;
  final String suggestedCefr;

  @override
  State<SaveWordDeckSheet> createState() => _SaveWordDeckSheetState();
}

enum _SheetState { loading, error, ready }

class _SaveWordDeckSheetState extends State<SaveWordDeckSheet> {
  final HomeController controller = Get.find<HomeController>();

  _SheetState _state = _SheetState.loading;
  List<VocabDeck> _decks = const [];
  bool _busy = false; // đang lưu / tạo bộ — chặn double tap

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _SheetState.loading);
    try {
      final decks = await controller.loadSavableDecks();
      if (!mounted) return;
      setState(() {
        _decks = decks;
        _state = _SheetState.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _SheetState.error);
    }
  }

  Future<void> _saveTo(VocabDeck deck) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final created = await controller.saveWordToDeck(deck);
      if (!mounted) return;
      Get.back();
      if (created) {
        AppNotify.success('Đã lưu từ', message: '"${widget.word}" đã thêm vào "${deck.title}".');
      } else {
        AppNotify.info('Từ đã có sẵn', message: '"${widget.word}" đã có trong "${deck.title}".');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppNotify.error('Lưu thất bại', message: 'Không lưu được từ. Vui lòng thử lại.');
    }
  }

  Future<void> _createThenSave() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final deck = await controller.createDeckForLevel(widget.suggestedCefr);
      await _saveTo(deck);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppNotify.error('Tạo bộ thẻ thất bại', message: 'Không tạo được bộ thẻ. Vui lòng thử lại.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    'Lưu "${widget.word}" vào bộ thẻ',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(Icons.close_rounded, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_state) {
      case _SheetState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      case _SheetState.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Text(
                'Không tải được bộ thẻ.',
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _load,
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
      case _SheetState.ready:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_decks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Bạn chưa có bộ thẻ riêng nào. Tạo một bộ để bắt đầu lưu từ.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _decks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _DeckTile(
                    deck: _decks[i],
                    enabled: !_busy,
                    onTap: () => _saveTo(_decks[i]),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _createThenSave,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Tạo bộ thẻ ${widget.suggestedCefr} & lưu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.deck,
    required this.enabled,
    required this.onTap,
  });

  final VocabDeck deck;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                deck.cefrLevel,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.title,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${deck.flashcardCount} thẻ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.bookmark_add_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
