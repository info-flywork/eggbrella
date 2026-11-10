import 'package:flutter/material.dart';

/// Tek satırlık etiket: sığmazsa "…" ile kesilmek ya da taşmak yerine
/// gerektiği kadar küçülür (uzun diller: Almanca, Fransızca, Rusça...).
/// Genişliği sınırlı bir kabın içinde (Expanded / Flexible / sabit genişlik)
/// kullanılmalıdır.
class AppFitText extends StatelessWidget {
  const AppFitText(
    this.text, {
    required this.style,
    this.alignment = Alignment.center,
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String text;
  final TextStyle style;
  final AlignmentGeometry alignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}
