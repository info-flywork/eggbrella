import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ekrana girişte gecikmeli kayma + belirme (+ isteğe bağlı büyüme).
class AppEntrance extends StatefulWidget {
  const AppEntrance({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 24),
    this.scaleFrom = 1,
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double scaleFrom;
  final Curve curve;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.delayed(widget.delay, () {
        if (mounted) unawaited(_controller.forward());
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final t = _t.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: widget.offset * (1 - t),
            child: Transform.scale(
              scale: widget.scaleFrom + (1 - widget.scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Yavaşça yukarı aşağı süzülme (Yumi bekleme animasyonu).
class AppFloat extends StatefulWidget {
  const AppFloat({
    required this.child,
    this.amplitude = 8,
    this.period = const Duration(milliseconds: 2400),
    this.sway = 0.03,
    super.key,
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  /// Hafif sallanma açısı (radyan).
  final double sway;

  @override
  State<AppFloat> createState() => _AppFloatState();
}

class _AppFloatState extends State<AppFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final a = _controller.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, math.sin(a) * widget.amplitude),
          child: Transform.rotate(
            angle: math.sin(a) * widget.sway,
            child: child,
          ),
        );
      },
    );
  }
}

/// Sürekli hafif nabız (ör. "Başlamak için dokun").
class AppPulse extends StatefulWidget {
  const AppPulse({required this.child, this.scale = 0.06, super.key});

  final Widget child;
  final double scale;

  @override
  State<AppPulse> createState() => _AppPulseState();
}

class _AppPulseState extends State<AppPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 1.0, end: 1 + widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    ),
    child: widget.child,
  );
}
