import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/shell/shell_controller.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_navigation.dart';
import 'package:englishme/routes/app_routes.dart';
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
      bottomNavigationBar: AppBottomNav(
        initialIndex: 1,
        onTap: (index, _) => ShellController.goToTab(index),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: _onBack),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Bảng IPA',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              AppGap.h20,
              Expanded(
                child: ListView(
                  children: [
                    _IpaSection(
                      title: 'Nguyên âm đơn (Monophthongs)',
                      items: _monophthongs,
                    ),
                    AppGap.h20,
                    _IpaSection(
                      title: 'Nguyên âm đôi (Diphthongs)',
                      items: _diphthongs,
                    ),
                    AppGap.h20,
                    _IpaSection(
                      title: 'Phụ âm (Consonants)',
                      items: _consonants,
                    ),
                    AppGap.h20,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IpaSection extends StatelessWidget {
  const _IpaSection({required this.title, required this.items});

  final String title;
  final List<_IpaPhoneme> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headlineMedium.copyWith(fontSize: 18),
        ),
        AppGap.h12,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _IpaTile(phoneme: item)).toList(),
        ),
      ],
    );
  }
}

class _IpaTile extends StatelessWidget {
  const _IpaTile({required this.phoneme});

  final _IpaPhoneme phoneme;

  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => tts.speak(phoneme.soundHint),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '/${phoneme.symbol}/',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(Icons.volume_up_rounded, size: 16, color: AppColors.tertiary),
                ],
              ),
              AppGap.h6,
              Text(
                phoneme.exampleWord,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
