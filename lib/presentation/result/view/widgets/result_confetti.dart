part of '../result_view.dart';

/// Figma yeni-rekor "Konfeti": yeşil, sarı, kırmızı, gök mavisi ve beyaz
/// küçük şeritler; yukarıdan dönerek düşer.
class ResultConfetti extends StatefulWidget {
  const ResultConfetti({super.key});

  @override
  State<ResultConfetti> createState() => _ResultConfettiState();
}

class _ResultConfettiState extends State<ResultConfetti>
    with SingleTickerProviderStateMixin {
  static const List<Color> _colors = [
    ColorName.colorGreen,
    ColorName.colorYellow,
    ColorName.colorRed,
    ColorName.colorSky,
    ColorName.colorWhite,
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  late final List<_Piece> _pieces = List.generate(44, (i) {
    final r = math.Random(i * 7919);
    return _Piece(
      x: r.nextDouble(),
      phase: r.nextDouble(),
      speed: 0.6 + r.nextDouble() * 0.6,
      size: Size(8 + r.nextDouble() * 6, 12 + r.nextDouble() * 10),
      spin: (r.nextDouble() - 0.5) * 8,
      drift: (r.nextDouble() - 0.5) * 40,
      color: _colors[i % _colors.length],
    );
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_pieces, _controller),
        size: Size.infinite,
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
    required this.spin,
    required this.drift,
    required this.color,
  });

  final double x;
  final double phase;
  final double speed;
  final Size size;
  final double spin;
  final double drift;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.animation) : super(repaint: animation);

  final List<_Piece> pieces;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (final p in pieces) {
      final progress = (t * p.speed + p.phase) % 1;
      final y = -30 + progress * (size.height + 60);
      final x =
          p.x * size.width + math.sin(progress * 6 + p.phase * 9) * p.drift;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(progress * p.spin)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size.width,
              height: p.size.height,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = p.color,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
