import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IpaScreen extends StatelessWidget {
  const IpaScreen({super.key});

  void _onBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
      return;
    }
    ShellController.goToTab(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AppMainAppBar(
                title: 'Bảng IPA',
                showBack: true,
                showSettings: false,
                horizontalPadding: 0,
                onBack: _onBack,
              ),
            ),
            AppGap.h8,
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                'Chạm vào mỗi ký hiệu để nghe phát âm qua từ ví dụ.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: const [
                  _IpaSection(
                    title: 'Nguyên âm đơn',
                    subtitle: 'Monophthongs',
                    icon: Icons.circle_outlined,
                    accent: _IpaAccent.vowel,
                    items: _monophthongs,
                  ),
                  AppGap.h22,
                  _IpaSection(
                    title: 'Nguyên âm đôi',
                    subtitle: 'Diphthongs',
                    icon: Icons.all_inclusive_rounded,
                    accent: _IpaAccent.diphthong,
                    items: _diphthongs,
                  ),
                  AppGap.h22,
                  _IpaSection(
                    title: 'Phụ âm',
                    subtitle: 'Consonants',
                    icon: Icons.graphic_eq_rounded,
                    accent: _IpaAccent.consonant,
                    items: _consonants,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nhóm âm. Màu dùng chung tông primary toàn màn để đồng nhất với app —
/// phân biệt nhóm qua title + icon, không qua màu.
enum _IpaAccent { vowel, diphthong, consonant }

extension _IpaAccentColors on _IpaAccent {
  Color get bg => AppColors.primarySoft;

  Color get fg => AppColors.primaryContainer;
}

class _IpaSection extends StatelessWidget {
  const _IpaSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _IpaAccent accent;
  final List<_IpaPhoneme> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 20, color: accent.fg),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineMedium.copyWith(fontSize: 17),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.bg,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${items.length} âm',
                style: AppTypography.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent.fg,
                ),
              ),
            ),
          ],
        ),
        AppGap.h14,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (_, index) =>
              _IpaTile(phoneme: items[index], accent: accent),
        ),
      ],
    );
  }
}

class _IpaTile extends StatelessWidget {
  const _IpaTile({required this.phoneme, required this.accent});

  final _IpaPhoneme phoneme;
  final _IpaAccent accent;

  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();

    return Obx(() {
      final isPlaying = tts.speakingText.value == phoneme.exampleWord;
      return Material(
        color: isPlaying ? accent.bg : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () => tts.speak(phoneme.exampleWord),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isPlaying ? accent.fg : AppColors.outlineVariant,
                width: isPlaying ? 2 : 1,
              ),
              boxShadow: isPlaying
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.neutralShadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    isPlaying
                        ? Icons.volume_up_rounded
                        : Icons.volume_up_outlined,
                    size: 15,
                    color: isPlaying ? accent.fg : AppColors.iconMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  '/${phoneme.symbol}/',
                  style: AppTypography.ipa.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isPlaying ? accent.fg : AppColors.primary,
                  ),
                ),
                AppGap.h4,
                Text(
                  phoneme.exampleWord,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _IpaPhoneme {
  final String symbol;
  final String soundHint;
  final String exampleWord;

  const _IpaPhoneme(this.symbol, this.soundHint, this.exampleWord);
}

// --------------- Monophthongs (Nguyên âm đơn) ---------------
const _monophthongs = [
  _IpaPhoneme('iː', 'ee', 'see'),
  _IpaPhoneme('ɪ', 'ih', 'sit'),
  _IpaPhoneme('e', 'eh', 'bed'),
  _IpaPhoneme('æ', 'aa', 'cat'),
  _IpaPhoneme('ɑː', 'aah', 'father'),
  _IpaPhoneme('ɒ', 'o', 'hot'),
  _IpaPhoneme('ɔː', 'aw', 'door'),
  _IpaPhoneme('ʊ', 'oo', 'put'),
  _IpaPhoneme('uː', 'ooh', 'blue'),
  _IpaPhoneme('ʌ', 'uh', 'cup'),
  _IpaPhoneme('ɜː', 'urr', 'bird'),
  _IpaPhoneme('ə', 'uh', 'about'),
];

// --------------- Diphthongs (Nguyên âm đôi) ---------------
const _diphthongs = [
  _IpaPhoneme('eɪ', 'ey', 'day'),
  _IpaPhoneme('aɪ', 'ai', 'my'),
  _IpaPhoneme('ɔɪ', 'oy', 'boy'),
  _IpaPhoneme('aʊ', 'ow', 'now'),
  _IpaPhoneme('oʊ', 'oh', 'go'),
  _IpaPhoneme('ɪə', 'ee uh', 'near'),
  _IpaPhoneme('eə', 'eh uh', 'hair'),
  _IpaPhoneme('ʊə', 'oo uh', 'pure'),
];

// --------------- Consonants (Phụ âm) ---------------
const _consonants = [
  _IpaPhoneme('p', 'puh', 'pen'),
  _IpaPhoneme('b', 'buh', 'bad'),
  _IpaPhoneme('t', 'tuh', 'tea'),
  _IpaPhoneme('d', 'duh', 'dog'),
  _IpaPhoneme('tʃ', 'chuh', 'chair'),
  _IpaPhoneme('dʒ', 'juh', 'just'),
  _IpaPhoneme('k', 'kuh', 'cat'),
  _IpaPhoneme('g', 'guh', 'get'),
  _IpaPhoneme('f', 'fuh', 'fish'),
  _IpaPhoneme('v', 'vuh', 'very'),
  _IpaPhoneme('θ', 'thuh', 'think'),
  _IpaPhoneme('ð', 'the', 'this'),
  _IpaPhoneme('s', 'suh', 'say'),
  _IpaPhoneme('z', 'zuh', 'zoo'),
  _IpaPhoneme('ʃ', 'shuh', 'she'),
  _IpaPhoneme('ʒ', 'zhuh', 'measure'),
  _IpaPhoneme('h', 'huh', 'hat'),
  _IpaPhoneme('m', 'muh', 'man'),
  _IpaPhoneme('n', 'nuh', 'no'),
  _IpaPhoneme('ŋ', 'ung', 'sing'),
  _IpaPhoneme('l', 'luh', 'leg'),
  _IpaPhoneme('r', 'ruh', 'red'),
  _IpaPhoneme('w', 'wuh', 'wet'),
  _IpaPhoneme('j', 'yuh', 'yes'),
];
