import 'package:equatable/equatable.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

final class GameStarted extends GameEvent {
  const GameStarted();
}

/// Hazır / ipucu ekranında dokunuş.
final class GameScreenTapped extends GameEvent {
  const GameScreenTapped();
}

/// Dünyadan: altın toplandı.
final class GameCoinCollected extends GameEvent {
  const GameCoinCollected();
}

/// Dünyadan: kırıldı.
final class GameCrashed extends GameEvent {
  const GameCrashed({required this.floor});

  final int floor;

  @override
  List<Object?> get props => [floor];
}

final class GameContinueTapped extends GameEvent {
  const GameContinueTapped();
}

/// "Hayır, teşekkürler" ya da süre doldu.
final class GameContinueDeclined extends GameEvent {
  const GameContinueDeclined();
}

final class GamePauseTapped extends GameEvent {
  const GamePauseTapped({required this.floor});

  final int floor;

  @override
  List<Object?> get props => [floor];
}

final class GameResumeTapped extends GameEvent {
  const GameResumeTapped();
}

/// Duraklatma > Ana sayfa.
final class GameExitTapped extends GameEvent {
  const GameExitTapped();
}

/// Çıkış onayı > Hayır, devam et.
final class GameExitCancelled extends GameEvent {
  const GameExitCancelled();
}

/// Çıkış onayı > Evet, çık (skor rekora sayılır).
final class GameExitConfirmed extends GameEvent {
  const GameExitConfirmed();
}

/// Uygulama arka plana gitti: oyun duraklar.
final class GameBackgrounded extends GameEvent {
  const GameBackgrounded({required this.floor});

  final int floor;

  @override
  List<Object?> get props => [floor];
}

/// İç zamanlayıcı tıkı (devam teklifi / sayaç).
final class GameTicked extends GameEvent {
  const GameTicked();
}
