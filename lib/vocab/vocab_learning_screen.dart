import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/theme/app_theme.dart';

enum _VocabStep { preview, reveal, done }

class VocabLearningScreen extends StatefulWidget {
  const VocabLearningScreen({super.key});

  @override
  State<VocabLearningScreen> createState() => _VocabLearningScreenState();
}

class _VocabLearningScreenState extends State<VocabLearningScreen> {
  _VocabStep _step = _VocabStep.preview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: _buildStep(context),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _VocabStep.preview:
        return _PreviewStep(
          onClose: () => Navigator.of(context).pop(),
          onReveal: () => setState(() => _step = _VocabStep.reveal),
        );
      case _VocabStep.reveal:
        return _RevealStep(
          onClose: () => Navigator.of(context).pop(),
          onRate: (_) => setState(() => _step = _VocabStep.done),
        );
      case _VocabStep.done:
        return _DoneStep(onBackHome: () => Navigator.of(context).popUntil((r) => r.isFirst));
    }
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.onClose, required this.onReveal});

  final VoidCallback onClose;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VocabTopBar(progress: 0, onClose: onClose),
        AppGap.h24,
        const _SkillPill(label: 'TỪ VỰNG • SM-2'),
        AppGap.h16,
        const _WordPreviewCard(),
        AppGap.h24,
        AppButton(
          label: 'XEM NGHĨA',
          onPressed: onReveal,
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }
}

class _RevealStep extends StatelessWidget {
  const _RevealStep({required this.onClose, required this.onRate});

  final VoidCallback onClose;
  final ValueChanged<String> onRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VocabTopBar(progress: 0.2, onClose: onClose),
        AppGap.h24,
        const _SkillPill(label: 'TỪ VỰNG • SM-2'),
        AppGap.h16,
        const _WordMeaningCard(),
        AppGap.h16,
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                title: 'Quên',
                subtitle: '< 1 phút',
                color: AppColors.danger,
                shadow: AppColors.dangerDark,
                onTap: () => onRate('again'),
              ),
            ),
            AppGap.w10,
            Expanded(
              child: _RatingButton(
                title: 'Khó',
                subtitle: '6 phút',
                color: const Color(0xFFFF7A12),
                shadow: const Color(0xFFC45400),
                onTap: () => onRate('hard'),
              ),
            ),
          ],
        ),
        AppGap.h10,
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                title: 'Dễ',
                subtitle: '1 ngày',
                color: AppColors.primary,
                shadow: AppColors.primaryDark,
                onTap: () => onRate('good'),
              ),
            ),
            AppGap.w10,
            Expanded(
              child: _RatingButton(
                title: 'Rất dễ',
                subtitle: '4 ngày',
                color: AppColors.success,
                shadow: AppColors.successShadow,
                onTap: () => onRate('easy'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AppBackButton(onPressed: onBackHome),
          ],
        ),
        AppGap.h24,
        const _DoneMascot(),
        AppGap.h14,
        Text(
          'Tuyệt vời!',
          style: AppTypography.displayLarge.copyWith(fontSize: 44 * 0.7),
        ),
        AppGap.h6,
        Text(
          'Bạn vừa ôn xong 3 thẻ từ vựng.',
          style: AppTypography.body.copyWith(fontSize: 14),
        ),
        AppGap.h20,
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.bolt_rounded,
                iconColor: Color(0xFFF4B12D),
                value: '+30',
                label: 'XP kiếm được',
              ),
            ),
            AppGap.w12,
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.danger,
                value: '8 ngày',
                label: 'Streak',
              ),
            ),
          ],
        ),
        AppGap.h24,
        AppButton(
          label: 'QUAY LẠI TRANG CHỦ',
          onPressed: onBackHome,
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }
}

class _VocabTopBar extends StatelessWidget {
  const _VocabTopBar({required this.progress, required this.onClose});

  final double progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: AppColors.iconMuted, size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
        ),
        AppGap.w10,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.progressTrack,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ),
        AppGap.w12,
        Text(
          '1/3',
          style: AppTypography.body.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 24 * 0.6,
          ),
        ),
      ],
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _WordPreviewCard extends StatelessWidget {
  const _WordPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book_rounded, size: 78, color: AppColors.primary),
          AppGap.h14,
          Text(
            'diligent',
            style: AppTypography.displayLarge.copyWith(fontSize: 56 * 0.7),
          ),
          AppGap.h8,
          Text(
            '/ˈdɪlɪdʒənt/',
            style: AppTypography.body.copyWith(fontSize: 16, color: AppColors.textMuted),
          ),
          AppGap.h6,
          Text(
            'ADJ',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          AppGap.h12,
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 28),
          ),
          AppGap.h8,
          Text(
            'CHẠM ĐỂ XEM NGHĨA',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordMeaningCard extends StatelessWidget {
  const _WordMeaningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'diligent',
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 40 * 0.7,
            ),
          ),
          AppGap.h6,
          Text(
            '/ˈdɪlɪdʒənt/ • adj',
            style: AppTypography.body.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          AppGap.h14,
          _InfoBox(
            title: 'NGHĨA',
            content: 'chăm chỉ, siêng năng',
          ),
          AppGap.h12,
          _InfoBox(
            title: 'VÍ DỤ',
            content: 'She is a diligent student who always\ndoes her homework.',
            secondary:
                'Cô ấy là một học sinh chăm chỉ luôn làm bài\ntập về nhà.',
          ),
          AppGap.h12,
          Center(
            child: Text(
              'ĐÁNH GIÁ KHẢ NĂNG GHI NHỚ BÊN DƯỚI ↓',
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.title,
    required this.content,
    this.secondary,
  });

  final String title;
  final String content;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w800,
            ),
          ),
          AppGap.h6,
          Text(
            content,
            style: AppTypography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18 * 0.9,
              height: 1.2,
            ),
          ),
          if (secondary != null) ...[
            AppGap.h8,
            Text(
              secondary!,
              style: AppTypography.body.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 14 * 0.9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.shadow,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: shadow, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(66),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.displayLarge.copyWith(
                color: Colors.white,
                fontSize: 20 * 0.7,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneMascot extends StatelessWidget {
  const _DoneMascot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(color: AppColors.primaryDark, width: 4),
      ),
      child: const Icon(Icons.flutter_dash, color: AppColors.primarySoft, size: 84),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppGap.h10,
          Text(
            value,
            style: AppTypography.displayLarge.copyWith(fontSize: 38 * 0.6),
          ),
          AppGap.h6,
          Text(label, style: AppTypography.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
