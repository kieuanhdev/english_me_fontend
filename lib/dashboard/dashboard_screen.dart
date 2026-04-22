import 'package:flutter/material.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/profile/profile_screen.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:englishme/vocab/vocab_learning_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DashboardStats(),
              AppGap.h16,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  'Xin chào, Minh Anh! 👋',
                  style: AppTypography.displayLarge.copyWith(fontSize: 38 * 0.7),
                ),
              ),
              AppGap.h6,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  'Hôm nay học thêm 15 phút nhé!',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              AppGap.h12,
              const _DailyGoalCard(),
              AppGap.h16,
              const _UnitCard(),
              AppGap.h22,
              const _LearningPath(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _DashboardStats extends StatelessWidget {
  const _DashboardStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _StatChip(icon: Icons.language, text: 'VI', bg: AppColors.primary)),
        AppGap.w8,
        Expanded(child: _StatChip(icon: Icons.local_fire_department, text: '7', bg: AppColors.danger)),
        AppGap.w8,
        Expanded(child: _StatChip(icon: Icons.bolt, text: '1,240', bg: AppColors.skillVocabulary, textColor: AppColors.text)),
        AppGap.w8,
        Expanded(child: _StatChip(icon: Icons.favorite, text: '5', bg: AppColors.skillListening)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.text,
    required this.bg,
    this.textColor = Colors.white,
  });

  final IconData icon;
  final String text;
  final Color bg;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor),
          AppGap.w8,
          Text(
            text,
            style: AppTypography.body.copyWith(
              fontSize: 18 * 0.8,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.neutralShadow, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.5,
                  strokeWidth: 5,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Center(
                  child: Text(
                    '50%',
                    style: AppTypography.body.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mục tiêu hôm nay',
                  style: AppTypography.displayLarge.copyWith(fontSize: 24 * 0.7),
                ),
                AppGap.h6,
                Text(
                  '15 / 30 phút • còn 2 bài học',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: AppColors.textMuted,
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

class _UnitCard extends StatelessWidget {
  const _UnitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Text(
            'UNIT 1 • A1',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w800,
            ),
          ),
          AppGap.w10,
          Expanded(
            child: Text(
              'Chào hỏi & Giới thiệu',
              style: AppTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18 * 0.9,
              ),
            ),
          ),
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

class _LearningPath extends StatelessWidget {
  const _LearningPath();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _PathNode(
                  done: true,
                  color: AppColors.skillVocabulary,
                  expand: true,
                ),
              ),
              AppGap.w12,
              const Expanded(
                child: _PathNode(
                  done: true,
                  color: AppColors.skillVocabulary,
                  expand: true,
                ),
              ),
              AppGap.w12,
              const Expanded(
                child: _PathNode(
                  done: false,
                  color: AppColors.primary,
                  label: 'BẮT ĐẦU',
                  expand: true,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: AppColors.primarySoft,
                    border: Border.all(color: AppColors.neutralShadow, width: 2),
                  ),
                  child: const Icon(Icons.flutter_dash, size: 52, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          AppGap.h14,
          const Row(
            children: [
              Spacer(),
              Expanded(child: _LockedNode(expand: true)),
              AppGap.w12,
              Expanded(child: _LockedNode(expand: true)),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.done,
    required this.color,
    this.label,
    this.expand = false,
  });

  final bool done;
  final Color color;
  final String? label;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: expand ? double.infinity : 86,
          height: expand ? 110 : 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color == AppColors.primary ? AppColors.primaryDark : const Color(0xFFC28712),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 40),
        ),
        if (done)
          Positioned(
            right: -2,
            top: -6,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.skillVocabulary, width: 2),
              ),
              child: const Icon(Icons.check, size: 18, color: AppColors.skillVocabulary),
            ),
          ),
        if (label != null)
          Positioned(
            top: -16,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Text(
                label!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LockedNode extends StatelessWidget {
  const _LockedNode({this.expand = false});

  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : 84,
      height: expand ? 102 : 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFB9C5D2),
        boxShadow: [
          BoxShadow(color: Color(0xFF93A1B0), offset: Offset(0, 4)),
        ],
      ),
      child: const Icon(Icons.lock_outline, color: Colors.white, size: 38),
    );
  }
}

class _BottomNav extends StatefulWidget {
  const _BottomNav();

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const List<({IconData icon, String label})> items = [
      (icon: Icons.home_outlined, label: 'Trang chủ'),
      (icon: Icons.style_outlined, label: 'Từ vựng'),
      (icon: Icons.mic_none_rounded, label: 'AI'),
      (icon: Icons.emoji_events_outlined, label: 'Thành tích'),
      (icon: Icons.person_outline_rounded, label: 'Cá nhân'),
    ];

    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: _NavItem(
                icon: items[i].icon,
                label: items[i].label,
                active: i == _currentIndex,
                onTap: () {
                  setState(() => _currentIndex = i);
                  if (i == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VocabLearningScreen(),
                      ),
                    );
                  }
                  if (i == 4) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.75);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          AppGap.h6,
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
