import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/modules/vocab_hub/controllers/vocab_topic_controller.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';

class VocabSpellingResultScreen extends GetView<VocabTopicController> {
  const VocabSpellingResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final correct = controller.spellingCorrectCount;
    final total = controller.spellingResults.length;
    final pct = total > 0 ? (correct / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Kết quả luyện tập',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            AppGap.h28,
            _ScoreCircle(correct: correct, total: total, pct: pct),
            AppGap.h28,
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: controller.spellingResults.length,
                separatorBuilder: (_, __) => AppGap.h10,
                itemBuilder: (_, i) {
                  final r = controller.spellingResults[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: r.isCorrect ? AppColors.successPanel : AppColors.dangerPanel,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: r.isCorrect
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          r.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: r.isCorrect ? AppColors.success : AppColors.danger,
                          size: 20,
                        ),
                        AppGap.w10,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.word,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (!r.isCorrect) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Bạn gõ: "${r.userInput}"',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontSize: 12,
                                    color: AppColors.dangerDark,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: r.isCorrect
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            r.isCorrect ? 'Đúng' : 'Sai',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: r.isCorrect ? AppColors.successDark : AppColors.dangerDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.offNamedUntil(
                    AppRoutes.vocabWordList,
                    (r) => r.settings.name == AppRoutes.vocabWordList,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    'Về danh sách',
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.startSpelling,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: Text(
                    'Luyện lại',
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.correct, required this.total, required this.pct});
  final int correct;
  final int total;
  final int pct;

  Color get _color {
    if (pct >= 80) return AppColors.success;
    if (pct >= 50) return AppColors.primary;
    return AppColors.danger;
  }

  String get _message {
    if (pct >= 80) return 'Xuất sắc! 🎉';
    if (pct >= 50) return 'Khá tốt! 💪';
    return 'Cần luyện thêm 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: total > 0 ? correct / total : 0,
                strokeWidth: 10,
                backgroundColor: AppColors.outlineVariant,
                valueColor: AlwaysStoppedAnimation(_color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Text(
                  '$pct%',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _color,
                  ),
                ),
                Text(
                  '$correct/$total',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        AppGap.h16,
        Text(
          _message,
          style: AppTypography.displayLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
