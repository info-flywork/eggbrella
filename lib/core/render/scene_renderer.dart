import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:eggbrella/core/render/game_sprites.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/game/world/world_objects.dart';
import 'package:eggbrella/domain/game/world/world_snapshot.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Oyun sahnesini dünya biriminden ekrana çizer. Canlı oyun
/// ([ScenePainter]) ve klip üretimi aynı kodu kullanır.
class SceneRenderer {
  const SceneRenderer(this.sprites);

  final GameSprites sprites;

  /// Sprite içindeki gövde merkezi (genişlik/yükseklik oranı) ve dünya
  /// birimi boyutu. Boyutlar, yumurta gövdesi her pozda ~95 birim genişlikte
  /// görünecek şekilde ölçülmüştür (sakin / mutlu: yüksek çözünürlüklü yeni
  /// çizimler, `scripts/make_skins.py` ile aynı kabuk maskesiyle ölçüldü).
  static const ({ui.Offset anchor, ui.Size size}) _calm = (
    size: Size(163, 204),
    anchor: Offset(0.358, 0.742),
  );
  static const ({ui.Offset anchor, ui.Size size}) _happy = (
    size: Size(179, 215),
    anchor: Offset(0.386, 0.744),
  );
  static const ({ui.Offset anchor, ui.Size size}) _scared = (
    size: Size(112, 188),
    anchor: Offset(0.38, 0.70),
  );
  // Kalkan: yeni çizim (balon + şemsiye), gövde opak piksellerle ölçüldü.
  static const ({ui.Offset anchor, ui.Size size}) _shield = (
    size: Size(236, 235),
    anchor: Offset(0.417, 0.695),
  );

  void paint(
    Canvas canvas,
    Size size,
    WorldSnapshot s, {
    required double time,
    String? floorLabel,
  }) {
    final scale = size.width / GameConfig.worldWidth;
    final viewHeight = size.height / scale;
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..scale(scale)
      ..translate(_shake(s.crashAge), 0);
    _background(canvas, s, viewHeight);
    canvas
      ..save()
      ..translate(0, -s.cameraY);
    for (final o in s.obstacles) {
      if (o.rect.bottom < s.cameraY - 20) continue;
      if (o.rect.top > s.cameraY + viewHeight + 20) continue;
      _obstacle(canvas, o, s.time, time);
    }
    for (final c in s.coins) {
      if ((c.center.dy - s.cameraY).abs() > viewHeight + 40) continue;
      paintCoin(canvas, c.center, GameConfig.coinRadius * 2, spin: time);
    }
    _egg(canvas, s, time);
    canvas.restore();
    if (!s.crashed) _speedLines(canvas, s, viewHeight, time);
    if (floorLabel != null) _hud(canvas, floorLabel, s.coinBalance);
    canvas.restore();
  }

  // --- Arka plan ---

  void _background(Canvas canvas, WorldSnapshot s, double viewHeight) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    const w = GameConfig.worldWidth;
    final cam = s.cameraY;
    const intro = GameConfig.introImageHeight;
    const tileH = GameConfig.facadeTileHeight;
    final tint = _zoneTint(s.floor);
    if (tint != null) paint.colorFilter = tint;
    final facade = sprites.facade;
    var index = math.max(0, ((cam - intro) / tileH).floor());
    while (true) {
      final top = intro + index * tileH - cam;
      if (top > viewHeight) break;
      // Dikiş görünmesin diye 1 birim bindirme.
      canvas.drawImageRect(
        facade,
        _full(facade),
        Rect.fromLTWH(0, top - 0.5, w, tileH + 1),
        paint,
      );
      index++;
    }
    if (cam < intro) {
      final img = sprites.gameStart;
      // Görselin üst kısmı (çatı kenarı + ilk pencere sıraları).
      final srcH = intro * img.width / w;
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), srcH),
        Rect.fromLTWH(0, -cam, w, intro),
        paint..colorFilter = null,
      );
    }
    // Çatı: oyun burada başlar. Taş kenarı cephe korkuluğunun üstüne oturur;
    // ana sayfadaki ölçekle (yükseklik = 932) ortalanmış çizilir.
    const roofBottom = GameConfig.facadeParapetBottom;
    if (cam < roofBottom) {
      final img = sprites.rooftop;
      const k = GameConfig.roofScale;
      final width = img.width * k;
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), GameConfig.roofCutPx),
        Rect.fromLTWH(
          (w - width) / 2,
          GameConfig.roofTop - cam,
          width,
          GameConfig.roofCutPx * k,
        ),
        paint..colorFilter = null,
      );
    }
  }

  /// Bölgeler (Figma notu): 1-99 çatı tuğlası, 100+ cam ofis, 200+ neon.
  static ColorFilter? _zoneTint(int floor) {
    if (floor >= 200) {
      return const ColorFilter.mode(Color(0x668E44FF), BlendMode.overlay);
    }
    if (floor >= 100) {
      return const ColorFilter.mode(Color(0x5546A8E0), BlendMode.color);
    }
    return null;
  }

  void _speedLines(
    Canvas canvas,
    WorldSnapshot s,
    double viewHeight,
    double time,
  ) {
    if (s.umbrellaOpen) return;
    final t = ((s.speed - 380) / 300).clamp(0.0, 1.0);
    if (t <= 0) return;
    final img = sprites.speedLines;
    final jitter = math.sin(time * 40) * 6;
    canvas.drawImageRect(
      img,
      _full(img),
      Rect.fromLTWH(0, jitter, GameConfig.worldWidth, viewHeight),
      Paint()..color = Colors.white.withValues(alpha: 0.45 * t),
    );
  }

  // --- Engeller ---

  /// Sıra engelleri tam görsel olarak çizilir ve açıklıkla birlikte bütün
  /// halinde kayar: her parçanın iç ucu açıklığın kenarındadır, dış ucu
  /// duvarın (ekranın) dışına taşar. Görsel hiçbir zaman kırpılmaz.
  void _obstacle(Canvas canvas, Obstacle o, double worldTime, double time) {
    if (o.kind == ObstacleKind.pigeon) return _pigeon(canvas, o, time);
    const w = GameConfig.worldWidth;
    final (left, right) = o.partsAt(worldTime);
    final leftDst = Rect.fromLTRB(
      left.right - w,
      o.rect.top,
      left.right,
      o.rect.bottom,
    );
    final rightDst = Rect.fromLTRB(
      right.left,
      o.rect.top,
      right.left + w,
      o.rect.bottom,
    );
    switch (o.kind) {
      // Balkonun sağ ucunda direk var: soldaki olduğu gibi, sağdaki aynalı
      // çizilir ki iki direk de açıklığın kenarında dursun.
      case ObstacleKind.balcony:
        _sprite(canvas, sprites.balcony, leftDst);
        _sprite(canvas, sprites.balcony, rightDst, mirror: true);
      // İp: ipin iç ucu duvar makarasına bağlanır.
      case ObstacleKind.clothesline:
        _sprite(canvas, sprites.clothesline, leftDst);
        _sprite(canvas, sprites.clothesline, rightDst, mirror: true);
        _pulley(
          canvas,
          Offset(leftDst.right - 4, leftDst.top + leftDst.height * 0.1),
        );
        _pulley(
          canvas,
          Offset(rightDst.left + 4, rightDst.top + rightDst.height * 0.1),
        );
      case ObstacleKind.awning:
        _awning(canvas, leftDst, innerEdgeRight: true);
        _awning(canvas, rightDst, innerEdgeRight: false);
      case ObstacleKind.pigeon:
        break;
    }
  }

  void _sprite(Canvas canvas, ui.Image img, Rect dst, {bool mirror = false}) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (!mirror) {
      canvas.drawImageRect(img, _full(img), dst, paint);
      return;
    }
    canvas
      ..save()
      ..translate(dst.center.dx, 0)
      ..scale(-1, 1)
      ..translate(-dst.center.dx, 0)
      ..drawImageRect(img, _full(img), dst, paint)
      ..restore();
  }

  /// İp ucundaki küçük makara (ipin havada kesik görünmemesi için).
  void _pulley(Canvas canvas, Offset c) {
    canvas
      ..drawCircle(
        c.translate(0, 2),
        9,
        Paint()..color = const Color(0x33000000),
      )
      ..drawCircle(c, 9, Paint()..color = const Color(0xFF6B4A2E))
      ..drawCircle(c, 5.5, Paint()..color = const Color(0xFFB98A5A))
      ..drawCircle(c, 2.2, Paint()..color = const Color(0xFF4A3220));
  }

  void _pigeon(Canvas canvas, Obstacle o, double time) {
    final img = sprites.pigeon;
    final bob = math.sin(time * 9 + o.id) * 4;
    final dst = o.rect.translate(0, bob);
    final paint = Paint()..filterQuality = FilterQuality.medium;
    // Görsel sola bakıyor; sağa uçan güvercin aynalanır.
    if (o.velocityX > 0) {
      canvas
        ..save()
        ..translate(dst.center.dx, 0)
        ..scale(-1, 1)
        ..translate(-dst.center.dx, 0)
        ..drawImageRect(img, _full(img), dst, paint)
        ..restore();
    } else {
      canvas.drawImageRect(img, _full(img), dst, paint);
    }
  }

  /// Çizgili tente parçası (Figma'da bina görseline gömülü; burada çizilir).
  /// Çizgiler iç uçtan başlar ki tente kayarken çizgiler de onunla kaysın.
  void _awning(Canvas canvas, Rect r, {required bool innerEdgeRight}) {
    final shade = r.height * 0.62;
    const stripe = 22.0;
    final inner = innerEdgeRight ? r.right : r.left;
    final dir = innerEdgeRight ? -1.0 : 1.0;
    final count = (r.width / stripe).ceil();
    canvas.drawRect(
      Rect.fromLTRB(r.left, r.top + shade - 4, r.right, r.bottom - 4),
      Paint()..color = const Color(0x33000000),
    );
    for (var i = 0; i < count; i++) {
      final x0 = inner + dir * i * stripe;
      final x1 = x0 + dir * stripe;
      final color = i.isEven ? ColorName.colorRed : ColorName.colorWhite;
      final band = Rect.fromLTRB(
        math.min(x0, x1),
        r.top,
        math.max(x0, x1),
        r.top + shade,
      );
      canvas
        ..drawRect(band, Paint()..color = color)
        // Fistolu alt kenar.
        ..drawArc(
          Rect.fromLTWH(band.left, r.top + shade - stripe / 2, stripe, stripe),
          0,
          math.pi,
          true,
          Paint()..color = color,
        );
    }
    final frame = Paint()..color = const Color(0xFF8E2422);
    canvas
      ..drawRect(Rect.fromLTRB(r.left, r.top, r.right, r.top + 3), frame)
      // İç uçta kenar çıtası.
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inner - (innerEdgeRight ? 4 : 0), r.top, 4, shade + 6),
          const Radius.circular(2),
        ),
        frame,
      );
  }

  // --- Yumi ---

  /// Kırılma anında sahne kısa süre yatay sarsılır.
  static double _shake(double crashAge) {
    const duration = 0.35;
    if (crashAge < 0 || crashAge > duration) return 0;
    return math.sin(crashAge * 70) * 7 * (1 - crashAge / duration);
  }

  /// Figma kırık yumurta: çarptığı yerde, gövdenin biraz altına (sarısı
  /// çarptığı yüzeye yayılır) hızla "patlayarak" belirir.
  void _brokenEgg(Canvas canvas, WorldSnapshot s) {
    final img = sprites.yumi(YumiPose.broken);
    final t = (s.crashAge / 0.22).clamp(0.0, 1.0);
    final scale = 0.55 + 0.45 * Curves.easeOutBack.transform(t);
    const width = 176.0;
    final height = width * img.egg.height / img.egg.width;
    final dst = Rect.fromCenter(
      center: Offset(s.eggX, s.eggY + 14),
      width: width * scale,
      height: height * scale,
    );
    _layers(canvas, img, dst, Paint()..filterQuality = FilterQuality.medium);
  }

  /// Skin katmanları: şemsiye kubbesi altta, yumurta üstte (pikseller ayrık;
  /// aynı saydamlıkla çizilince birleşik görselle aynıdır).
  static void _layers(Canvas canvas, YumiLayers img, Rect dst, Paint paint) {
    canvas
      ..drawImageRect(img.umbrella, _full(img.umbrella), dst, paint)
      ..drawImageRect(img.egg, _full(img.egg), dst, paint);
  }

  /// Yumi: ifadeler ani değişmez, ağırlıklarına göre üst üste çapraz
  /// geçişle çizilir (korkmuş ↔ sakin ↔ mutlu, koruma sonunda söner).
  /// Coin alınca gövde merkezinden esneyip toparlanır.
  void _egg(Canvas canvas, WorldSnapshot s, double time) {
    if (s.crashed) return _brokenEgg(canvas, s);
    final center = Offset(s.eggX, s.eggY);
    final shield = (s.shieldLeft / 0.3).clamp(0.0, 1.0);
    final rest = 1 - shield;
    final open = s.openBlend;
    final layers = <(({Size size, Offset anchor}), YumiLayers, double)>[
      (_scared, sprites.yumi(YumiPose.scared), rest * (1 - open)),
      (_calm, sprites.yumi(YumiPose.calm), rest * open * (1 - s.happyBlend)),
      (_happy, sprites.yumi(YumiPose.happy), rest * open * s.happyBlend),
      (_shield, sprites.yumi(YumiPose.shield), shield),
    ];
    if (shield > 0) _shieldGlow(canvas, center, _shield, time, shield);

    // Açıkken salınım yönüne hafif yatış (kapanırken yumuşakça söner).
    final tilt = math.sin(time * 1.9) * 0.05 * open;
    final b = s.bounce;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(tilt)
      ..scale(1 - b * 0.55, 1 + b)
      ..translate(-center.dx, -center.dy);
    // En ağır katman tam opak altta; diğerleri üstüne saydamlıkla biner,
    // böylece geçişte gövde hiç yarı saydam görünmez.
    layers.sort((x, y) => y.$3.compareTo(x.$3));
    for (var i = 0; i < layers.length; i++) {
      final (spec, img, weight) = layers[i];
      final alpha = i == 0 ? 1.0 : weight / (layers[0].$3 + weight);
      if (alpha <= 0.01) continue;
      final topLeft = center.translate(
        -spec.size.width * spec.anchor.dx,
        -spec.size.height * spec.anchor.dy,
      );
      _layers(
        canvas,
        img,
        topLeft & spec.size,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = Color.fromRGBO(0, 0, 0, alpha),
      );
    }
    canvas.restore();
  }

  /// Figma "Koruma parıltısı": 250 birimlik sarı radyal parıltı.
  void _shieldGlow(
    Canvas canvas,
    Offset body,
    ({Size size, Offset anchor}) spec,
    double time,
    double opacity,
  ) {
    final center = body.translate(
      spec.size.width * (0.5 - spec.anchor.dx),
      spec.size.height * (0.5 - spec.anchor.dy),
    );
    final pulse = 1 + math.sin(time * 6) * 0.04;
    final radius = 125 * pulse;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            const Color(0xFFFFC83D).withValues(alpha: 0.55 * opacity),
            const Color(0xFFFFC83D).withValues(alpha: 0.25 * opacity),
            const Color(0x00FFC83D),
          ],
          const [0, 0.7, 1],
        ),
    );
  }

  // --- HUD (yalnızca klipte; canlı oyunda widget'lar çizer) ---

  void _hud(Canvas canvas, String floorLabel, int coins) {
    final floor = TextPainter(
      text: TextSpan(
        text: floorLabel,
        style: AppTextStyles.hudFloor.copyWith(
          color: ColorName.colorWhite,
          shadows: AppShadows.floorText,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    floor.paint(
      canvas,
      Offset(
        (GameConfig.worldWidth - floor.width) / 2,
        AppSpacing.screenTop + 1.5,
      ),
    );
    final amount = TextPainter(
      text: TextSpan(
        text: '$coins',
        style: AppTextStyles.hudCoins.copyWith(color: ColorName.colorWhite),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pillW = 6 + 32 + 6 + amount.width + 14;
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(GameConfig.worldWidth - 16 - pillW, 104, pillW, 40),
      const Radius.circular(20),
    );
    canvas.drawRRect(pill, Paint()..color = ColorName.colorNavy);
    paintCoin(canvas, Offset(pill.left + 6 + 16, pill.center.dy), 32);
    amount.paint(
      canvas,
      Offset(pill.left + 6 + 32 + 6, pill.center.dy - amount.height / 2),
    );
  }

  static Rect _full(ui.Image img) =>
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());

  /// Figma "Coin" vektörü: sarı gövde, koyu sarı halka ve yıldız.
  /// [spin] verilirse para yatayda döner.
  static void paintCoin(
    Canvas canvas,
    Offset center,
    double size, {
    double? spin,
  }) {
    final k = size / 40;
    canvas
      ..save()
      ..translate(center.dx, center.dy);
    if (spin != null) {
      final sx = math.cos(spin * 3 + center.dy * 0.05).abs() * 0.7 + 0.3;
      canvas.scale(sx, 1);
    }
    canvas.drawCircle(
      Offset.zero,
      18.5 * k,
      Paint()..color = ColorName.colorYellow,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = ColorName.colorYellowDark;
    canvas
      ..drawCircle(Offset.zero, 18.5 * k, stroke..strokeWidth = 3 * k)
      ..drawCircle(Offset.zero, 12.333 * k, stroke..strokeWidth = 2 * k);
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final r = (i.isEven ? 6.667 : 2.79) * k;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas
      ..drawPath(star..close(), Paint()..color = ColorName.colorYellowDark)
      ..restore();
  }
}

/// Canlı oyun için CustomPainter. [repaint] her karede tetiklenir.
class ScenePainter extends CustomPainter {
  ScenePainter({
    required this.renderer,
    required this.snapshot,
    required this.time,
    super.repaint,
  });

  final SceneRenderer renderer;
  final WorldSnapshot Function() snapshot;
  final double Function() time;

  @override
  void paint(Canvas canvas, Size size) =>
      renderer.paint(canvas, size, snapshot(), time: time());

  @override
  bool shouldRepaint(ScenePainter oldDelegate) =>
      oldDelegate.renderer != renderer;
}
