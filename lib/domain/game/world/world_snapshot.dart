import 'package:eggbrella/domain/game/world/world_objects.dart';

/// Bir karenin çizim için gereken değişmez görüntüsü. Hem canlı oyun hem
/// klip (son 8 sn'nin tekrar çizimi) aynı ressamla bunu çizer.
final class WorldSnapshot {
  const WorldSnapshot({
    required this.cameraY,
    required this.eggX,
    required this.eggY,
    required this.time,
    required this.umbrellaOpen,
    required this.scared,
    required this.happy,
    required this.shieldLeft,
    required this.speed,
    required this.floor,
    required this.obstacles,
    required this.coins,
    this.openBlend = 1,
    this.happyBlend = 0,
    this.bounce = 0,
    this.crashAge = -1,
    this.coinBalance = 0,
  });

  final double cameraY;
  final double eggX;
  final double eggY;

  /// Dünya saati (engel sıralarının sallanma konumu).
  final double time;
  final bool umbrellaOpen;
  final bool scared;
  final bool happy;

  /// Çapraz geçiş ağırlıkları (0..1): şemsiye açıklığı ve mutluluk.
  final double openBlend;
  final double happyBlend;

  /// Coin esnemesi: + dikey uzama, - basılma.
  final double bounce;
  final double shieldLeft;

  /// Kırıldıysa kırılmadan bu yana geçen süre (sn); canlıyken -1.
  final double crashAge;

  bool get crashed => crashAge >= 0;
  final double speed;
  final int floor;
  final List<Obstacle> obstacles;
  final List<Coin> coins;

  /// HUD'daki bakiye (klip çiziminde kullanılır).
  final int coinBalance;

  WorldSnapshot withBalance(int balance) => WorldSnapshot(
    cameraY: cameraY,
    eggX: eggX,
    eggY: eggY,
    time: time,
    umbrellaOpen: umbrellaOpen,
    scared: scared,
    happy: happy,
    openBlend: openBlend,
    happyBlend: happyBlend,
    bounce: bounce,
    shieldLeft: shieldLeft,
    crashAge: crashAge,
    speed: speed,
    floor: floor,
    obstacles: obstacles,
    coins: coins,
    coinBalance: balance,
  );
}
