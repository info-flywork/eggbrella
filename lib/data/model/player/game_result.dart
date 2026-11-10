import 'package:eggbrella/domain/game/replay/game_replay.dart';
import 'package:equatable/equatable.dart';

/// Bitmiş bir oyunun özeti (oyun ekranı -> sonuç ekranı).
class GameResult extends Equatable {
  const GameResult({
    required this.floor,
    required this.coinsEarned,
    required this.previousBest,
    this.replay,
  });

  final int floor;
  final int coinsEarned;

  /// Bu oyundan önceki rekor (ilk oyunda 0).
  final int previousBest;

  /// Son saniyelerin kareleri (klip için); kayıt yoksa null.
  final GameReplay? replay;

  bool get isNewRecord => floor > previousBest;

  int get bestFloor => isNewRecord ? floor : previousBest;

  @override
  List<Object?> get props => [floor, coinsEarned, previousBest, replay];
}
