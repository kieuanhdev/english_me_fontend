import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/core/widgets/word_card_parts.dart';
import 'package:englishme/modules/vocab_hub/models/vocab_word_model.dart';
import 'package:englishme/modules/study_session/controllers/study_session_controller.dart';
import 'package:englishme/modules/study_session/views/study_session_card_back_screen.dart';
import 'package:englishme/theme/app_theme.dart';

class StudySessionFrontScreen extends GetView<StudySessionController> {
  const StudySessionFrontScreen({super.key});

  ApiState _mapState(StudySessionController c) {
    if (c.isLoading.value) return ApiState.loading;
    if (c.errorMessage.isNotEmpty) return ApiState.error;
    if (c.cards.isEmpty) return ApiState.empty;
    return ApiState.success;
  }

  void _showSettingsSheet(BuildContext context) {
    final tts = Get.find<TtsService>();
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.progressTrack,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              AppGap.h16,
              Text(
                'Cài đặt phiên học',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppGap.h8,
              Obx(
                () => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: tts.autoSpeak.value,
                  onChanged: tts.setAutoSpeak,
                  activeColor: AppColors.primary,
                  title: Text(
                    'Tự phát âm khi mở thẻ mới',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Đọc từ tự động mỗi khi chuyển sang thẻ tiếp theo.',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 13,
                      color: AppColors.iconMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: Obx(
        () => controller.isCardFlipped.value
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: StudySessionRatingGrid(
                    onRate: controller.rateCard,
                    isLoading: controller.isReviewing.value,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Obx(() {
          return ApiStateView(
            state: _mapState(controller),
            errorMessage: controller.errorMessage.value.isEmpty
                ? null
                : controller.errorMessage.value,
            emptyMessage: 'Không có từ nào để học trong bộ thẻ này.',
            emptyIcon: Icons.style_outlined,
            onRetry: controller.retryLoad,
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SessionAppBar(
                  title: controller.deskTitle,
                  onClose: controller.closeSession,
                  onSettings: () => _showSettingsSheet(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    () => _ProgressSection(
                      current: controller.currentIndex.value + 1,
                      total: controller.totalCards,
                    ),
                  ),
                ),
                AppGap.h16,
                // Vùng card cuộn toàn bộ; thẻ co theo nội dung và căn giữa khi ngắn,
                // nên mặt trước gọn còn mặt sau dài thì cuộn cả màn (không cuộn trong thẻ).
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.42,
                      ),
                      child: Center(
                        child: Obx(
                          () => _FlipCard(
                            // currentIndex trong key → reset về mặt trước khi sang thẻ mới.
                            key: ValueKey(controller.currentIndex.value),
                            flipped: controller.isCardFlipped.value,
                            onFlip: controller.flipCard,
                            front: _FlashcardFront(
                              card: controller.currentCard,
                              onSpeak: controller.speak,
                            ),
                            back: StudySessionFlashcardBack(
                              card: controller.currentCard,
                              onSpeak: controller.speak,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AppGap.h16,
                Obx(
                  () => controller.isCardFlipped.value
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: _TopicTip(
                            topic: controller.currentCard.topicId,
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Flip Card (hiệu ứng lật 3D) ────────────────────────────────────────────────

/// Lật thẻ 3D: xoay quanh trục Y, đổi mặt khi vượt 90°, xoay ngược mặt sau để
/// chữ đọc được. Cùng cơ chế với card lật bên màn từ vựng (topic).
/// Trạng thái lật do controller giữ (truyền qua `flipped`); widget tự chạy animation
/// khi `flipped` đổi. Reset về mặt trước khi sang thẻ mới nhờ `ValueKey(currentIndex)`.
class _FlipCard extends StatefulWidget {
  const _FlipCard({
    super.key,
    required this.flipped,
    required this.front,
    required this.back,
    required this.onFlip,
  });

  final bool flipped;
  final Widget front;
  final Widget back;
  final VoidCallback onFlip;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      value: widget.flipped ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.flipped != old.flipped) {
      // Lật QUA LẠI: animate cả 2 chiều theo trạng thái flipped.
      widget.flipped ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap cả 2 mặt để lật qua lại tự do.
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_ctrl.value);
          final angle = t * math.pi;
          final showBack = t >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // perspective
              ..rotateY(angle),
            child: showBack
                // Đã xoay >90° → mặt sau bị soi gương; xoay ngược lại cho chữ đọc được.
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _SessionAppBar extends StatelessWidget {
  const _SessionAppBar({
    required this.title,
    required this.onClose,
    required this.onSettings,
  });
  final String title;
  final VoidCallback onClose;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          AppCloseButton(onPressed: onClose),
          AppGap.w8,
          Text(
            title.isNotEmpty ? title : 'Daily Session',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_rounded, size: 22),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─── Progress ────────────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: '$current',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: '/$total',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.iconMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'SESSION PROGRESS',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.iconMuted,
              ),
            ),
          ],
        ),
        AppGap.h8,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: AppColors.progressTrack),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentWarm, const Color(0xFFD4761A)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Flashcard Front ─────────────────────────────────────────────────────────

class _FlashcardFront extends StatelessWidget {
  const _FlashcardFront({required this.card, required this.onSpeak});
  final VocabWord card;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final posLabel = card.pos.isNotEmpty ? card.pos.first : '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Word area
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 28,
                  color: AppColors.levelCFg,
                ),
                AppGap.h14,
                Text(
                  card.word,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppGap.h12,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (posLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          posLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    AppGap.w8,
                    WordSpeakButton(
                      onTap: onSpeak,
                      size: 32,
                      iconSize: 17,
                      color: AppColors.primaryContainer,
                    ),
                  ],
                ),
                if (card.ipa.isNotEmpty) ...[
                  AppGap.h8,
                  Text(
                    card.ipa,
                    style: AppTypography.ipa.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            AppGap.h24,
            // Gợi ý lật — tap vào cả thẻ để xem nghĩa (không cần nút riêng).
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: AppColors.iconMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Nhấn vào thẻ để xem nghĩa',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.iconMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Topic Tip ───────────────────────────────────────────────────────────────

class _TopicTip extends StatelessWidget {
  const _TopicTip({required this.topic});
  final String topic;

  @override
  Widget build(BuildContext context) {
    if (topic.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow,
            ),
            child: Icon(Icons.tag_rounded, color: AppColors.primary, size: 19),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chủ đề',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.onSurface.withValues(alpha: 0.65),
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
