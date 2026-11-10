import 'package:bloc_test/bloc_test.dart';
import 'package:eggbrella/core/haptics/haptic_manager.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:eggbrella/data/model/player/player_progress.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/domain/settings/settings_repository.dart';
import 'package:eggbrella/presentation/game/bloc/game_bloc.dart';
import 'package:eggbrella/presentation/game/bloc/game_event.dart';
import 'package:eggbrella/presentation/game/bloc/game_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Player extends Mock implements PlayerRepository {}

class _Settings extends Mock implements SettingsRepository {}

class _Sound extends Mock implements SoundManager {}

class _Haptics extends Mock implements HapticManager {}

void main() {
  late _Player player;
  late _Settings settings;

  setUpAll(() => registerFallbackValue(GameSound.tap));

  setUp(() {
    player = _Player();
    settings = _Settings();
    when(() => settings.controlMode).thenReturn(ControlMode.hold);
    when(
      () => player.recordGame(
        floor: any(named: 'floor'),
        coinsCollected: any(named: 'coinsCollected'),
        continuesUsed: any(named: 'continuesUsed'),
        durationMs: any(named: 'durationMs'),
      ),
    ).thenAnswer((_) async => const PlayerProgress());
    when(
      () => player.spendForContinue(any()),
    ).thenAnswer((_) async => const PlayerProgress());
  });

  GameBloc build() {
    final sound = _Sound();
    final haptics = _Haptics();
    when(
      () => sound.play(any(), volume: any(named: 'volume')),
    ).thenReturn(null);
    return GameBloc(player, settings, sound, haptics);
  }

  /// Sprite yüklemesi testte yapılamadığı için başlangıç durumu verilir.
  GameState ready({int coins = 100}) =>
      GameState(phase: GamePhase.ready, coinBalance: coins);

  blocTest<GameBloc, GameState>(
    'hazır ekranında dokunuş oyunu başlatır',
    build: build,
    seed: ready,
    act: (bloc) => bloc.add(const GameScreenTapped()),
    expect: () => [
      isA<GameState>().having((s) => s.phase, 'phase', GamePhase.playing),
    ],
  );

  blocTest<GameBloc, GameState>(
    'altın toplamak bakiyeyi artırır',
    build: build,
    seed: () => ready().copyWith(phase: GamePhase.playing),
    act: (bloc) => bloc
      ..add(const GameCoinCollected())
      ..add(const GameCoinCollected()),
    verify: (bloc) {
      expect(bloc.state.coinsEarned, 2);
      expect(bloc.state.displayedCoins, 102);
    },
  );

  blocTest<GameBloc, GameState>(
    'kırılınca kırılma, sonra devam teklifi gelir',
    build: build,
    seed: () => ready().copyWith(phase: GamePhase.playing),
    act: (bloc) => bloc.add(const GameCrashed(floor: 12)),
    wait: GameBloc.crashDuration + const Duration(milliseconds: 100),
    expect: () => [
      isA<GameState>()
          .having((s) => s.phase, 'phase', GamePhase.crashed)
          .having((s) => s.floor, 'floor', 12),
      isA<GameState>()
          .having((s) => s.phase, 'phase', GamePhase.continueOffer)
          .having((s) => s.secondsLeft, 'secondsLeft', GameBloc.offerSeconds),
    ],
  );

  blocTest<GameBloc, GameState>(
    'devam: bedel önce kazanılan coinlerden düşer, sayaç başlar',
    build: build,
    seed: () => ready().copyWith(
      phase: GamePhase.continueOffer,
      coinsEarned: 30,
      secondsLeft: 4,
    ),
    act: (bloc) => bloc.add(const GameContinueTapped()),
    verify: (bloc) {
      verify(() => player.spendForContinue(20)).called(1);
      expect(bloc.state.phase, GamePhase.countdown);
      expect(bloc.state.coinsEarned, 0);
      expect(bloc.state.coinBalance, 80);
      expect(bloc.state.revive, 1);
      expect(bloc.state.continuesUsed, 1);
    },
  );

  blocTest<GameBloc, GameState>(
    'bakiye yetmezse devam edilmez',
    build: build,
    seed: () => ready(coins: 10).copyWith(phase: GamePhase.continueOffer),
    act: (bloc) => bloc.add(const GameContinueTapped()),
    expect: () => <GameState>[],
  );

  blocTest<GameBloc, GameState>(
    'reddedince oyun kaydedilir ve sonuç ekranına geçilir',
    build: build,
    seed: () => ready().copyWith(
      phase: GamePhase.continueOffer,
      floor: 33,
      coinsEarned: 7,
    ),
    act: (bloc) => bloc.add(const GameContinueDeclined()),
    verify: (bloc) {
      expect(bloc.state.phase, GamePhase.finished);
      expect(bloc.state.result?.floor, 33);
      expect(bloc.state.result?.coinsEarned, 7);
    },
  );

  blocTest<GameBloc, GameState>(
    'duraklatma > ana sayfa > onay: skor kaydedilir, ana sayfaya dönülür',
    build: build,
    seed: () => ready().copyWith(phase: GamePhase.playing),
    act: (bloc) => bloc
      ..add(const GamePauseTapped(floor: 8))
      ..add(const GameExitTapped())
      ..add(const GameExitConfirmed()),
    verify: (bloc) {
      expect(bloc.state.phase, GamePhase.finished);
      expect(bloc.state.exitToHome, isTrue);
      expect(bloc.state.floor, 8);
    },
  );

  blocTest<GameBloc, GameState>(
    'duraklatmadan dönüş oyunda sayaçla olur',
    build: build,
    seed: () => ready().copyWith(phase: GamePhase.playing),
    act: (bloc) => bloc
      ..add(const GamePauseTapped(floor: 3))
      ..add(const GameResumeTapped()),
    expect: () => [
      isA<GameState>().having((s) => s.phase, 'phase', GamePhase.paused),
      isA<GameState>()
          .having((s) => s.phase, 'phase', GamePhase.countdown)
          .having((s) => s.secondsLeft, 'secondsLeft', 3),
    ],
  );
}
