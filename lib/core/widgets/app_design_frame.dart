import 'dart:math' as math;

import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Figma kareleri 430x932 ve arka planlar 1024x1536 (object-cover). Arka
/// plandaki bir yere "oturan" öğeler (çatıdaki Yumi gibi) ekran oranı
/// değişse de aynı yerde kalsın diye arka planla aynı ölçekte konumlanır.
abstract final class AppDesignFrame {
  static const Size frame = Size(430, 932);
  static const Size background = Size(1024, 1536);

  /// Figma'daki arka plan ölçeğine göre ekrandaki ölçek oranı.
  static double scaleOf(Size screen, {Size bg = background}) {
    final figma = math.max(
      frame.width / bg.width,
      frame.height / bg.height,
    );
    final actual = math.max(screen.width / bg.width, screen.height / bg.height);
    return actual / figma;
  }

  /// Figma karesindeki dikdörtgeni ekrana taşır (yatayda ortalı, üstten).
  static Rect map(Rect figma, Size screen, {Size bg = background}) {
    final k = scaleOf(screen, bg: bg);
    return Rect.fromLTWH(
      screen.width / 2 + (figma.left - frame.width / 2) * k,
      figma.top * k,
      figma.width * k,
      figma.height * k,
    );
  }
}

/// Arka plana bağlı konumlanan öğe (Stack içinde).
class AppDesignPositioned extends StatelessWidget {
  const AppDesignPositioned({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.child,
    this.background = AppDesignFrame.background,
    super.key,
  });

  /// Konumun bağlı olduğu arka plan görselinin piksel boyutu.
  final Size background;
  final double left;
  final double top;
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rect = AppDesignFrame.map(
      Rect.fromLTWH(left, top, width, height),
      MediaQuery.sizeOf(context),
      bg: background,
    );
    return Positioned.fromRect(rect: rect, child: child);
  }
}

/// Figma ekran dolgusu: yanlarda 16, üstte güvenli alan + 8 (Figma 54),
/// altta ev çubuğu (Figma 34).
class AppScreenPadding extends StatelessWidget {
  const AppScreenPadding({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.m,
        insets.top + AppSpacing.xs,
        AppSpacing.m,
        math.max(insets.bottom, AppSpacing.m),
      ),
      child: child,
    );
  }
}
