part of '../game_view.dart';

mixin GameViewMixin on State<GameView>, TickerProvider {
  GameBloc get _bloc => context.read<GameBloc>();

  GameWorldController? worldController;
  AppLifecycleListener? _lifecycle;
  final Set<int> _pointers = {};
  int _revive = 0;
  GamePhase _phase = GamePhase.loading;

  ControlMode get controlMode => _bloc.controlMode;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onInactive: () => _bloc.add(
        GameBackgrounded(floor: worldController?.currentFloor ?? 0),
      ),
    );
    unawaited(GameSprites.load(_bloc.replay.skins).then(_onSpritesLoaded));
  }

  void _onSpritesLoaded(GameSprites sprites) {
    if (!mounted) return;
    setState(() {
      worldController = GameWorldController(
        vsync: this,
        sprites: sprites,
        replay: _bloc.replay,
        sound: getIt<SoundManager>(),
        coinBalance: () => _bloc.state.displayedCoins,
        onCoin: () => _bloc.add(const GameCoinCollected()),
        onCrash: (floor) => _bloc.add(GameCrashed(floor: floor)),
      )..setControlMode(controlMode);
    });
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    worldController?.dispose();
    super.dispose();
  }

  void onStateChanged(BuildContext context, GameState state) {
    final world = worldController;
    if (world != null) {
      world.setRunning(value: state.isWorldRunning);
      if (state.revive != _revive) {
        _revive = state.revive;
        world.revive();
      } else if (state.phase == GamePhase.countdown &&
          _phase != GamePhase.countdown) {
        world.grantShield();
      }
    }
    _phase = state.phase;
    if (state.phase == GamePhase.finished) {
      final result = state.result;
      if (state.exitToHome || result == null) {
        context.go(RoutePaths.home.path);
      } else {
        context.go(RoutePaths.result.path, extra: result);
      }
    }
  }

  /// Arayüz düğmesine (Pause) inen parmaklar şemsiyeyi oynatmaz.
  final Set<int> _uiPointers = {};

  void onUiPointerDown(int pointer) => _uiPointers.add(pointer);

  void onPointerDown(PointerDownEvent event) {
    if (_uiPointers.contains(event.pointer)) return;
    _pointers.add(event.pointer);
    worldController?.pointerDown();
  }

  void onPointerUp(PointerEvent event) {
    if (_uiPointers.remove(event.pointer)) return;
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) worldController?.pointerUp();
  }

  void onScreenTapped() => _bloc.add(const GameScreenTapped());

  void onPauseTapped() =>
      _bloc.add(GamePauseTapped(floor: worldController?.currentFloor ?? 0));

  void onResumeTapped() => _bloc.add(const GameResumeTapped());

  void onExitTapped() => _bloc.add(const GameExitTapped());

  void onExitCancelled() => _bloc.add(const GameExitCancelled());

  void onExitConfirmed() => _bloc.add(const GameExitConfirmed());

  void onContinueTapped() => _bloc.add(const GameContinueTapped());

  void onDeclineTapped() => _bloc.add(const GameContinueDeclined());

  /// Duraklatma > Ayarlar; dönüşte kontrol modu güncellenir.
  Future<void> onSettingsTapped() async {
    await context.pushNamed<void>(RoutePaths.settings.name);
    if (!mounted) return;
    worldController?.setControlMode(controlMode);
    setState(() {});
  }
}
