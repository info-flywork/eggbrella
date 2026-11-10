import 'package:flutter/material.dart';

/// Basınca hafifçe küçülüp aşağı inen dokunma alanı (oyunsu buton hissi).
class AppPressable extends StatefulWidget {
  const AppPressable({
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.pressedOffset = 3,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Basılıyken aşağı kayma (Figma: buton "tabanı" 3-4 px).
  final double pressedOffset;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.onPressed == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.55,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 90),
            scale: _pressed ? 0.97 : 1,
            child: Transform.translate(
              offset: Offset(0, _pressed ? widget.pressedOffset : 0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
