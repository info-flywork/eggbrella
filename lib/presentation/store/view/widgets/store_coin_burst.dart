part of '../store_view.dart';

/// Coin satın alma kutlaması: coinler dokunulan noktadan patlayıp kavisle
/// üstteki bakiye hapına uçar; her varışta hap zıplar, bakiye eski
/// değerden yenisine sayar, "+N" yazısı yükselip söner. Ses ve titreşim
/// varışlara eşlik eder.
class StoreCoinBurst extends StatefulWidget {
  const StoreCoinBurst({
    required this.from,
    required this.target,
    required this.fromCoins,
    required this.toCoins,
    required this.onFrame,
    required this.onDone,
    super.key,
  });

  /// Patlama noktası ve bakiye hapındaki coin ikonu (bu katmanın
  /// koordinatlarında).
  final Offset from;
  final Offset target;
  final int fromCoins;
  final int toCoins;

  /// Her karede gösterilecek bakiye ve hap zıplaması (0..1).
  final void Function(int coins, double bump) onFrame;
  final VoidCallback onDone;

  @override
  State<StoreCoinBurst> createState() => _StoreCoinBurstState();
}

class _StoreCoinBurstState extends State<StoreCoinBurst>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1900);

  /// Patlama süresi ve uçuşun başlangıcı / süresi (toplamın oranı).
  static const _burst = 0.16;
  static const _flyStart = 0.14;
  static const _flyStagger = 0.028;
  static const _fly = 0.36;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _total,
  );
  late final List<_FlyingCoin> _coins;
  int _arrived = 0;

  int get _gain => widget.toCoins - widget.fromCoins;

  @override
  void initState() {
    super.initState();
    final n = (8 + _gain ~/ 150).clamp(8, 18);
    final rnd = math.Random(_gain);
    _coins = [
      for (var i = 0; i < n; i++)
        _FlyingCoin(
          angle: (rnd.nextDouble() - 0.5) * math.pi * 1.3,
          radius: 55 + rnd.nextDouble() * 75,
          start: _flyStart + i * _flyStagger,
          spin: (rnd.nextDouble() - 0.5) * 6,
          size: 26 + rnd.nextDouble() * 10,
        ),
    ];
    getIt<HapticManager>().medium();
    _c.addListener(_tick);
    unawaited(_c.forward().whenComplete(widget.onDone));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _firstArrival => _coins.first.start + _fly;
  double get _lastArrival => _coins.last.start + _fly;

  void _tick() {
    final t = _c.value;
    final arrived = _coins.where((c) => t >= c.start + _fly).length;
    if (arrived > _arrived) {
      // Ses / titreşim her varışta değil, art arda iki varışta bir.
      for (var i = _arrived; i < arrived; i++) {
        if (i.isEven || i == _coins.length - 1) {
          getIt<SoundManager>().play(GameSound.coin, volume: 0.45);
          getIt<HapticManager>().light();
        }
      }
      _arrived = arrived;
    }
    final count = Curves.easeOut.transform(
      ((t - _firstArrival) / (_lastArrival - _firstArrival)).clamp(0.0, 1.0),
    );
    // Son varıştan bu yana geçen süreye göre sönen zıplama.
    var bump = 0.0;
    for (final c in _coins) {
      final since = t - (c.start + _fly);
      if (since >= 0 && since < 0.08) {
        bump = math.max(bump, 1 - since / 0.08);
      }
    }
    widget.onFrame(widget.fromCoins + (_gain * count).round(), bump);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _flash(t),
            for (final coin in _coins) ?_coin(coin, t),
            _gainLabel(t),
          ],
        );
      },
    );
  }

  /// Dokunulan noktada kısa sarı parlama.
  Widget _flash(double t) {
    final k = (t / 0.2).clamp(0.0, 1.0);
    if (k >= 1) return const SizedBox.shrink();
    final r = 30 + 90 * Curves.easeOut.transform(k);
    return Positioned(
      left: widget.from.dx - r,
      top: widget.from.dy - r,
      width: r * 2,
      height: r * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              ColorName.colorYellow.withValues(alpha: 0.55 * (1 - k)),
              ColorName.colorYellow.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _coin(_FlyingCoin c, double t) {
    final end = c.start + _fly;
    if (t >= end) return null;
    // Patlama yukarı ve ekranın ortasına doğru açılır (fiyat butonu sağ
    // kenara yakın); yine de ekran içinde kalır.
    final width = MediaQuery.sizeOf(context).width;
    final lean = ((width / 2 - widget.from.dx) / (width / 2)).clamp(-1.0, 1.0);
    final raw =
        widget.from +
        Offset.fromDirection(-math.pi / 2 - lean * 0.6 + c.angle, c.radius);
    final p1 = Offset(raw.dx.clamp(28.0, width - 28), raw.dy);
    final Offset pos;
    final double scale;
    if (t < c.start) {
      // Patlama: dışa savrulur, büyür.
      final k = Curves.easeOutCubic.transform((t / _burst).clamp(0.0, 1.0));
      pos = Offset.lerp(widget.from, p1, k)!;
      scale = 0.3 + 0.8 * k;
    } else {
      // Uçuş: yukarı kavisle bakiye hapına.
      final k = Curves.easeInCubic.transform((t - c.start) / _fly);
      final ctrl = Offset(
        p1.dx + (widget.target.dx - p1.dx) * 0.15,
        math.min(p1.dy, widget.target.dy) - 140,
      );
      final u = 1 - k;
      pos = p1 * (u * u) + ctrl * (2 * u * k) + widget.target * (k * k);
      scale = 1.1 - 0.5 * k;
    }
    final size = c.size * scale;
    return Positioned(
      left: pos.dx - size / 2,
      top: pos.dy - size / 2,
      child: Transform.rotate(
        angle: c.spin * t,
        child: AppCoinIcon(size: size),
      ),
    );
  }

  /// Bakiye hapının altında yükselip sönen "+N".
  Widget _gainLabel(double t) {
    final k = ((t - _firstArrival) / (1 - _firstArrival)).clamp(0.0, 1.0);
    if (k <= 0) return const SizedBox.shrink();
    final opacity = k < 0.2 ? k / 0.2 : (k > 0.75 ? (1 - k) / 0.25 : 1.0);
    return Positioned(
      left: widget.target.dx - 10,
      top: widget.target.dy + 26 - 22 * Curves.easeOut.transform(k),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Text(
          '+$_gain',
          style: AppTextStyles.hudCoins.copyWith(
            color: ColorName.colorWhite,
            shadows: AppShadows.floorText,
          ),
        ),
      ),
    );
  }
}

class _FlyingCoin {
  const _FlyingCoin({
    required this.angle,
    required this.radius,
    required this.start,
    required this.spin,
    required this.size,
  });

  /// Patlama yönü (yukarıya göre sapma, radyan) ve uzaklığı.
  final double angle;
  final double radius;
  final double start;
  final double spin;
  final double size;
}
