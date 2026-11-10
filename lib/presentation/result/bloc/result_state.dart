import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:eggbrella/domain/clip/clip_repository.dart';
import 'package:equatable/equatable.dart';

enum ClipStatus {
  idle,

  /// Figma klip-hazirlaniyor.
  preparing,

  /// Hazır: ekran sistem paylaşım sayfasını açar (Figma paylasim).
  sharing,

  /// Figma klip-hata.
  error,
}

final class ResultState extends Equatable {
  const ResultState({
    required this.result,
    this.clipStatus = ClipStatus.idle,
    this.clip,
  });

  final GameResult result;
  final ClipStatus clipStatus;

  /// Bir kez üretilen klip tekrar paylaşımda yeniden kullanılır.
  final Clip? clip;

  bool get canShareClip => result.replay != null;

  ResultState copyWith({ClipStatus? clipStatus, Clip? clip}) => ResultState(
    result: result,
    clipStatus: clipStatus ?? this.clipStatus,
    clip: clip ?? this.clip,
  );

  @override
  List<Object?> get props => [result, clipStatus, clip];
}
