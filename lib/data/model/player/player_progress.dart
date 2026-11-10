import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player_progress.g.dart';

/// `GET /player/progress`, `POST /player/game-over`, `POST /player/continue`
/// cevabı: sunucudaki oyuncu durumu.
@JsonSerializable()
class PlayerProgress extends Equatable implements BaseModel<PlayerProgress> {
  const PlayerProgress({
    this.coins = 0,
    this.bestFloor = 0,
    this.gamesPlayed = 0,
    this.continuePrice = 50,
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) =>
      _$PlayerProgressFromJson(json);

  /// Kırılınca devam etmenin bedeli (Figma: "Devam et · 50"); yapıcıdaki
  /// varsayılanla aynı tutulmalı (json_serializable sabiti kopyalayamıyor).
  static const int defaultContinuePrice = 50;

  final int coins;
  final int bestFloor;
  final int gamesPlayed;
  final int continuePrice;

  PlayerProgress copyWith({
    int? coins,
    int? bestFloor,
    int? gamesPlayed,
    int? continuePrice,
  }) => PlayerProgress(
    coins: coins ?? this.coins,
    bestFloor: bestFloor ?? this.bestFloor,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    continuePrice: continuePrice ?? this.continuePrice,
  );

  @override
  PlayerProgress fromJson(Map<String, dynamic> json) =>
      PlayerProgress.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerProgressToJson(this);

  @override
  List<Object?> get props => [coins, bestFloor, gamesPlayed, continuePrice];
}
