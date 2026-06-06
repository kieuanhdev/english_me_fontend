import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/widgets/api_state_view.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';
import 'package:englishme/modules/pronunciation/repositories/pronunciation_repository.dart';
import 'package:englishme/theme/app_theme.dart';

/// Màn "Điểm yếu phát âm" (P4) — tổng hợp lịch sử assess của user:
/// điểm TB, phân bố lỗi, và các từ phát âm yếu nhất kèm gợi ý luyện.
class PronunciationInsightScreen extends StatefulWidget {
  const PronunciationInsightScreen({super.key});

  @override
  State<PronunciationInsightScreen> createState() =>
      _PronunciationInsightScreenState();
}

class _PronunciationInsightScreenState
    extends State<PronunciationInsightScreen> {
  final PronunciationRepository _repo =
      PronunciationRepository(DioClient.instance);

  ApiState _state = ApiState.loading;
  PronunciationInsight? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = ApiState.loading);
    try {
      final result = await _repo.getInsights();
      setState(() {
        _data = result;
        _state = ApiState.success;
      });
    } catch (_) {
      setState(() => _state = ApiState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(
                title: 'Điểm yếu phát âm',
                showBack: true,
                showNotification: false,
                horizontalPadding: 0,
                onBack: () => Get.back<void>(),
              ),
              AppGap.h20,
              Expanded(
                child: ApiStateView(
                  state: _state,
                  errorMessage: 'Không tải được dữ liệu. Thử lại.',
                  onRetry: _load,
                  builder: (_) => _buildContent(_data!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PronunciationInsight d) {
    if (d.totalAttempts == 0) {
      return _EmptyState();
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        children: [
          _SummaryCard(insight: d),
          AppGap.h20,
          Text(
            'Từ cần luyện thêm',
            style: AppTypography.displayLarge.copyWith(fontSize: 17),
          ),
          AppGap.h12,
          if (d.weakestWords.isEmpty)
            Text(
              'Chưa phát hiện từ nào yếu. Tiếp tục luyện để có thêm dữ liệu.',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else
            ...d.weakestWords.map((w) => _WeakWordTile(word: w)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.insight});

  final PronunciationInsight insight;

  @override
  Widget build(BuildContext context) {
    final b = insight.issueBreakdown;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điểm trung bình',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onPrimaryFixed.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          AppGap.h6,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${insight.averageScore}',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 40,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
              Text(
                ' /100  ·  ${insight.totalAttempts} lần luyện',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  color: AppColors.onPrimaryFixed.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          AppGap.h16,
          Row(
            children: [
              _IssuePill(label: 'Tốt', count: b.good),
              AppGap.w8,
              _IssuePill(label: 'Cần chú ý', count: b.minor),
              AppGap.w8,
              _IssuePill(label: 'Lỗi nặng', count: b.critical),
            ],
          ),
        ],
      ),
    );
  }
}

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.onPrimaryFixed.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 18,
                color: AppColors.onPrimaryFixed,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.onPrimaryFixed.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeakWordTile extends StatelessWidget {
  const _WeakWordTile({required this.word});

  final WeakWord word;

  Color get _accent => switch (word.lastIssueType) {
        'critical' => AppColors.tertiary,
        'minor' => const Color(0xFF6750A4),
        _ => AppColors.primary,
      };

  String get _issueLabel => switch (word.lastIssueType) {
        'critical' => 'Lỗi nặng',
        'minor' => 'Cần chú ý',
        _ => 'Tốt',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _issueLabel,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Luyện ${word.attempts} lần · điểm TB ${word.avgScore}/100',
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          if (word.suggestion != null && word.suggestion!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.suggestion!,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 12,
                color: AppColors.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded,
              size: 56, color: AppColors.textSecondary),
          AppGap.h12,
          Text(
            'Chưa có dữ liệu phát âm',
            style: AppTypography.displayLarge.copyWith(fontSize: 17),
          ),
          AppGap.h6,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Luyện vài câu phát âm để app phân tích điểm yếu của bạn.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
