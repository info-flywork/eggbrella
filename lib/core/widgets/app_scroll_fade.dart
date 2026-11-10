import 'package:flutter/material.dart';

/// Kaydırılabilir içeriğin üst ve alt kenarını sert kesmek yerine yumuşakça
/// söndürür (ShaderMask ile saydamlık geçişi). İlk / son öğe solmuş
/// görünmesin diye içeriğe [fade] kadar dikey boşluk bırakılmalıdır.
class AppScrollFade extends StatelessWidget {
  const AppScrollFade({required this.child, this.fade = 28, super.key});

  final Widget child;

  /// Solma bandının yüksekliği (piksel).
  final double fade;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final f = (fade / bounds.height).clamp(0.0, 0.5);
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00000000),
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0x00000000),
          ],
          stops: [0, f, 1 - f, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
