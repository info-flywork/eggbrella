import 'dart:async';

import 'package:eggbrella/core/haptics/haptic_manager.dart';
import 'package:eggbrella/core/render/game_sprites.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/game/replay/game_replay.dart';
import 'package:eggbrella/domain/player/player_exceptions.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/domain/settings/settings_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/presentation/game/bloc/game_event.dart';
import 'package:eggbrella/presentation/game/bloc/game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Oyun akışı (Figma 01–04 bölümleri). Kare kare fizik ekranın
/// denetleyicisindedir; bloc yalnızca aşamaları, coin'i ve zamanlayıcıları
/// yönetir.
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(
    this._player,
    this._settings,
    this._sound,
    this._haptics, {
    SkinSelection skins = SkinSelection.classic,
  }) : replay = GameReplay(skins: skins),
       super(const GameState()) {
    on<GameStarted>(_onStarted);
    on<GameScreenTapped>(_onScreenTapped);
    on<GameCoinCollected>(_onCoinCollected);
    on<GameCrashed>(_onCrashed);
    on<GameTicked>(_onTicked);
    on<GameContinueTapped>(_onContinueTapped);
    on<GameContinueDeclined>(_onContinueDeclined);
    on<GamePauseTapped>(_onPauseTapped);
    on<GameBackgrounded>(_onBackgrounded);
    on<GameResumeTapped>(_onResumeTapped);
    on<GameExitTapped>(_onExitTapped);
    on<GameExitCancelled>(_onExitCancelled);
    on<GameExitConfirmed>(_onExitConfirmed);
  }

  final PlayerRepository _player;
  final SettingsRepository _settings;
  final SoundManager _sound;
  final HapticManager _haptics;

  /// Son saniyelerin kareleri; ekran her karede buraya yazar.
  final GameReplay replay;
  final Stopwatch _playTime = Stopwatch();
  Timer? _timer;
  bool _showHint = false;
  int _previousBest = 0;

  /// Figma kirilma: "~1 sn sonra devam-teklifi".
  static const crashDuration = Duration(milliseconds: 1100);

  /// Figma devam-teklifi: 5 sn geri sayım.
  static const offerSeconds = 5;

  /// Figma sayac: 3-2-1.
  static const countdownSeconds = 3;

  /// Ayarlardaki kontrol modu (her okunuşta günceldir; oyun içinden
  /// ayarlara gidilip değiştirilebilir).
  ControlMode get controlMode => _settings.controlMode;

  Future<void> _onStarted(GameStarted event, Emitter<GameState> emit) async {
    await GameSprites.load(replay.skins);
    final progress = _player.progress;
    _previousBest = progress.bestFloor;
    _showHint = progress.gamesPlayed < GameConfig.hintGames;
    emit(
      state.copyWith(
        phase: GamePhase.ready,
        coinBalance: progress.coins,
        continuePrice: progress.continuePrice,
      ),
    );
  }

  void _onScreenTapped(GameScreenTapped event, Emitter<GameState> emit) {
    switch (state.phase) {
      case GamePhase.ready when _showHint:
        _sound.play(GameSound.tap);
        emit(state.copyWith(phase: GamePhase.hint));
      case GamePhase.ready || GamePhase.hint:
        _sound.play(GameSound.go);
        _haptics.light();
        _playTime.start();
        emit(state.copyWith(phase: GamePhase.playing));
      case GamePhase.loading ||
          GamePhase.playing ||
          GamePhase.crashed ||
          GamePhase.continueOffer ||
          GamePhase.countdown ||
          GamePhase.paused ||
          GamePhase.exitConfirm ||
          GamePhase.finished:
        break;
    }
  }

  void _onCoinCollected(GameCoinCollected event, Emitter<GameState> emit) {
    _sound.play(GameSound.coin, volume: 0.5);
    _haptics.selection();
    emit(state.copyWith(coinsEarned: state.coinsEarned + 1));
  }

  void _onCrashed(GameCrashed event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.playing) return;
    _playTime.stop();
    _sound.play(GameSound.crack);
    _haptics.heavy();
    emit(state.copyWith(phase: GamePhase.crashed, floor: event.floor));
    _timer?.cancel();
    _timer = Timer(crashDuration, () => add(const GameTicked()));
  }

  Future<void> _onTicked(GameTicked event, Emitter<GameState> emit) async {
    switch (state.phase) {
      case GamePhase.crashed:
        emit(
          state.copyWith(
            phase: GamePhase.continueOffer,
            secondsLeft: offerSeconds,
          ),
        );
        _startTicker();
      case GamePhase.continueOffer:
        final left = state.secondsLeft - 1;
        if (left <= 0) {
          await _finish(emit);
        } else {
          emit(state.copyWith(secondsLeft: left));
        }
      case GamePhase.countdown:
        final left = state.secondsLeft - 1;
        if (left <= 0) {
          _timer?.cancel();
          _sound.play(GameSound.go);
          _playTime.start();
          emit(state.copyWith(phase: GamePhase.playing, secondsLeft: 0));
        } else {
          _sound.play(GameSound.beep);
          emit(state.copyWith(secondsLeft: left));
        }
      case GamePhase.loading ||
          GamePhase.ready ||
          GamePhase.hint ||
          GamePhase.playing ||
          GamePhase.paused ||
          GamePhase.exitConfirm ||
          GamePhase.finished:
        _timer?.cancel();
    }
  }

  Future<void> _onContinueTapped(
    GameContinueTapped event,
    Emitter<GameState> emit,
  ) async {
    if (state.phase != GamePhase.continueOffer || !state.canAffordContinue) {
      return;
    }
    _timer?.cancel();
    // Bedel önce bu oyunda toplanan coin'lerden, kalanı bakiyeden düşer.
    final price = state.continuePrice;
    final fromEarned = price <= state.coinsEarned ? price : state.coinsEarned;
    final fromBalance = price - fromEarned;
    try {
      await _player.spendForContinue(fromBalance);
    } on InsufficientCoinsException {
      emit(state.copyWith(coinBalance: _player.progress.coins));
      _startTicker();
      return;
    }
    _haptics.medium();
    _beginCountdown(
      emit,
      state.copyWith(
        coinBalance: state.coinBalance - fromBalance,
        coinsEarned: state.coinsEarned - fromEarned,
        continuesUsed: state.continuesUsed + 1,
        revive: state.revive + 1,
      ),
    );
  }

  Future<void> _onContinueDeclined(
    GameContinueDeclined event,
    Emitter<GameState> emit,
  ) async {
    if (state.phase != GamePhase.continueOffer) return;
    await _finish(emit);
  }

  void _onPauseTapped(GamePauseTapped event, Emitter<GameState> emit) =>
      _pause(emit, event.floor);

  void _onBackgrounded(GameBackgrounded event, Emitter<GameState> emit) {
    if (state.phase == GamePhase.playing ||
        state.phase == GamePhase.countdown) {
      _pause(emit, event.floor);
    }
  }

  void _pause(Emitter<GameState> emit, int floor) {
    final resumeTo = switch (state.phase) {
      GamePhase.ready || GamePhase.hint => state.phase,
      GamePhase.playing || GamePhase.countdown => GamePhase.countdown,
      _ => null,
    };
    if (resumeTo == null) return;
    _timer?.cancel();
    _playTime.stop();
    _sound.play(GameSound.tap);
    emit(
      state.copyWith(
        phase: GamePhase.paused,
        resumePhase: resumeTo,
        floor: floor,
      ),
    );
  }

  /// Figma duraklatma: "Devam et → sayac → oyun".
  void _onResumeTapped(GameResumeTapped event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.paused) return;
    if (state.resumePhase == GamePhase.countdown) {
      _beginCountdown(emit, state);
    } else {
      emit(state.copyWith(phase: state.resumePhase));
    }
  }

  void _onExitTapped(GameExitTapped event, Emitter<GameState> emit) {
    if (state.phase == GamePhase.paused) {
      emit(state.copyWith(phase: GamePhase.exitConfirm));
    }
  }

  void _onExitCancelled(GameExitCancelled event, Emitter<GameState> emit) {
    if (state.phase == GamePhase.exitConfirm) {
      emit(state.copyWith(phase: GamePhase.paused));
    }
  }

  /// Figma cikis-onayi: "Evet, çık → ana-sayfa (skor rekora sayılır)".
  Future<void> _onExitConfirmed(
    GameExitConfirmed event,
    Emitter<GameState> emit,
  ) async {
    if (state.phase != GamePhase.exitConfirm) return;
    await _finish(emit, exitToHome: true);
  }

  void _beginCountdown(Emitter<GameState> emit, GameState from) {
    _sound.play(GameSound.beep);
    emit(
      from.copyWith(phase: GamePhase.countdown, secondsLeft: countdownSeconds),
    );
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const GameTicked()),
    );
  }

  Future<void> _finish(
    Emitter<GameState> emit, {
    bool exitToHome = false,
  }) async {
    _timer?.cancel();
    _playTime.stop();
    final played = _playTime.elapsedMilliseconds > 0;
    if (played) {
      await _player.recordGame(
        floor: state.floor,
        coinsCollected: state.coinsEarned,
        continuesUsed: state.continuesUsed,
        durationMs: _playTime.elapsedMilliseconds,
      );
    }
    emit(
      state.copyWith(
        phase: GamePhase.finished,
        exitToHome: exitToHome || !played,
        result: GameResult(
          floor: state.floor,
          coinsEarned: state.coinsEarned,
          previousBest: _previousBest,
          replay: replay.isEmpty ? null : replay,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
