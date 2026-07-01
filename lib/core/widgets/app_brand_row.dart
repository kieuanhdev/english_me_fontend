import 'package:flutter/material.dart';

import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/core/widgets/app_text.dart';
import 'package:englishme/gen/assets.gen.dart';
import 'package:englishme/theme/app_theme.dart';

/// Hàng thương hiệu: logo + tên app "EnglishMe".
/// Dùng chung cho app bar welcome + login + register để 3 màn "mặt tiền" đồng nhất.
class AppBrandRow extends StatelessWidget {
  const AppBrandRow({super.key, this.logoSize = 40});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.images.iconAppEnglishMe.svg(
          width: logoSize,
          height: logoSize,
          semanticsLabel: 'Logo English Me',
        ),
        AppGap.w8,
        AppText(T.appName, style: AppTypography.brand),
      ],
    );
  }
}
