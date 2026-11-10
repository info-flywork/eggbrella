import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:equatable/equatable.dart';

/// Oyun ekranının aşamaları (Figma karelerine karşılık).
enum GamePhase {
  /// Yükleniyor (görseller / ilerleme).
  loading,

  /// oyun-baslangic: "Başlamak için dokun".
  ready,

  /// ipucu: ilk 3 oyunda kontrol kartı.
  hint,

  /// oyun-acik / oyun-kapali: dünya akıyor.
  playing,

  /// kirilma: ~1 sn kırılma sahnesi.
  crashed,

  /// devam-teklifi: 5 sn geri sayım, coin ile devam.
  continueOffer,

  /// sayac: 3-2-1 sonra oyun (koruma ile).
  countdown,

  /// duraklatma kartı.
  paused,

  /// cikis-onayi kartı.
  exitConfirm,

  /// Oyun bitti; sonuç ekranına geçiliyor.
  finished,
}

final class GameState extends Equatable {
  const GameState({
    this.phase = GamePhase.loading,
    this.resumePhase = GamePhase.ready,
    this.floor = 0,
    this.coinBalance = 0,
    this.coinsEarned = 0,
    this.continuePrice = 50,
    this.continuesUsed = 0,
    this.secondsLeft = 0,
    this.revive = 0,
    this.result,
    this.exitToHome = false,
  });

  final GamePhase phase;

  /// Duraklatmadan dönülecek aşama (hazır / ipucu ise oraya, oyun ise sayaç).
  final GamePhase resumePhase;

  /// Son bilinen kat (kırılma / duraklatma anında güncellenir; canlı HUD
  /// dünya denetleyicisinden okur).
  final int floor;

  /// Oyun öncesi bakiye (devam bedeli düşülmüş).
  final int coinBalance;

  /// Bu oyunda toplanan.
  final int coinsEarned;
  final int continuePrice;
  final int continuesUsed;

  /// Devam teklifi (5→0) ya da sayaç (3→1) için kalan.
  final int secondsLeft;

  /// Her devamda artar; ekran dünyayı canlandırır.
  final int revive;

  final GameResult? result;

  /// Çıkış onayıyla bitti: sonuç yerine ana sayfaya dönülür.
  final bool exitToHome;

  int get displayedCoins => coinBalance + coinsEarned;

  bool get canAffordContinue => coinBalance + coinsEarned >= continuePrice;

  /// Dünya yalnızca bu aşamada ilerler.
  bool get isWorldRunning => phase == GamePhase.playing;

  GameState copyWith({
    GamePhase? phase,
    GamePhase? resumePhase,
    int? floor,
    int? coinBalance,
    int? coinsEarned,
    int? continuePrice,
    int? continuesUsed,
    int? secondsLeft,
    int? revive,
    GameResult? result,
    bool? exitToHome,
  }) => GameState(
    phase: phase ?? this.phase,
    resumePhase: resumePhase ?? this.resumePhase,
    floor: floor ?? this.floor,
    coinBalance: coinBalance ?? this.coinBalance,
    coinsEarned: coinsEarned ?? this.coinsEarned,
    continuePrice: continuePrice ?? this.continuePrice,
    continuesUsed: continuesUsed ?? this.continuesUsed,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    revive: revive ?? this.revive,
    result: result ?? this.result,
    exitToHome: exitToHome ?? this.exitToHome,
  );

  @override
  List<Object?> get props => [
    phase,
    resumePhase,
    floor,
    coinBalance,
    coinsEarned,
    continuePrice,
    continuesUsed,
    secondsLeft,
    revive,
    result,
    exitToHome,
  ];
}
