import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class HomeWordOfDay extends GetView<HomeController> {
  const HomeWordOfDay({super.key});

  static const Color _bgColor = Color(0xFFFFEDD5);
  static const Color _wordColor = Color(0xFF854D00);
  static const Color _ipaColor = Color(0xFF693C00);
  static const Color _badgeBg = Color(0xFF2C1600);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final word = controller.wordOfDay;
      final state = controller.wordOfDayState.value;
      if (state == WordOfDayState.loading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _WordOfDayLoadingCard(),
        );
      }
      if (word == null) {
        if (state == WordOfDayState.empty || state == WordOfDayState.error) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WordOfDayMessageCard(
              message: controller.wordOfDayMessage.value,
              isError: state == WordOfDayState.error,
              onRetry: () => controller.loadWordOfDay(forceRefresh: true),
              onPlacement: controller.onStartPlacementTest,
            ),
          );
        }
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _badgeBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'TỪ VỰNG MỖI NGÀY',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.onPrimaryFixed,
                      ),
                    ),
                  ),
                  AppGap.h12,
                  Text(
                    word.word,
                    style: AppTypography.displayAccent.copyWith(
                      fontSize: 38,
                      color: _wordColor,
                      height: 1.1,
                    ),
                  ),
                  if (word.pronunciation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      word.pronunciation!,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: _ipaColor,
                      ),
                    ),
                  ],
                  AppGap.h14,
                  if (word.definitionEn != null)
                    Text(
                      word.definitionEn!,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                  if (word.definitionVi != null) ...[
                    AppGap.h6,
                    Text(
                      word.definitionVi!,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _ipaColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                  AppGap.h16,
                  Row(
                    children: [
                      Obx(() {
                        final playing = controller.wordPlaying.value;
                        return GestureDetector(
                          onTap: playing ? null : controller.onListenWordOfDay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: playing
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (playing)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimaryFixed,
                                    ),
                                  )
                                else
                                  Icon(Icons.volume_up_rounded, color: AppColors.onPrimaryFixed, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  playing ? 'Đang phát...' : 'Nghe phát âm',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onPrimaryFixed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 10),
                      Obx(() => GestureDetector(
                        onTap: controller.onAddWordToFlashcard,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: controller.wordSaved.value
                                ? _wordColor
                                : _bgColor,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: _wordColor.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.wordSaved.value
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_add_outlined,
                                color: controller.wordSaved.value
                                    ? AppColors.onPrimaryFixed
                                    : _wordColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.wordSaved.value ? 'Đã lưu' : 'Lưu từ',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: controller.wordSaved.value
                                      ? AppColors.onPrimaryFixed
                                      : _wordColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _WordOfDayLoadingCard extends StatelessWidget {
  const _WordOfDayLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HomeWordOfDay._bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: HomeWordOfDay._wordColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Đang tải từ vựng mỗi ngày...',
            style: AppTypography.bodyLarge.copyWith(
              color: HomeWordOfDay._ipaColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordOfDayMessageCard extends StatelessWidget {
  const _WordOfDayMessageCard({
    required this.message,
    required this.isError,
    required this.onRetry,
    required this.onPlacement,
  });

  final String message;
  final bool isError;
  final VoidCallback onRetry;
  final VoidCallback onPlacement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: HomeWordOfDay._bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.assignment_turned_in_rounded,
                color: HomeWordOfDay._wordColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Từ vựng mỗi ngày',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 18,
                  color: HomeWordOfDay._wordColor,
                ),
              ),
            ],
          ),
          AppGap.h8,
          Text(
            message.isEmpty ? 'Chưa có từ vựng mỗi ngày.' : message,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 13,
              color: HomeWordOfDay._ipaColor,
              height: 1.4,
            ),
          ),
          AppGap.h14,
          GestureDetector(
            onTap: isError ? onRetry : onPlacement,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Text(
                isError ? 'Thử lại' : 'Làm placement test',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
