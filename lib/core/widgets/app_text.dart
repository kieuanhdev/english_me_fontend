import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isTranslate; // Cho phép tắt/bật dịch nếu cần

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isTranslate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      isTranslate ? text.tr : text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
