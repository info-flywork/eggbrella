import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/render/game_sprites.dart';
import 'package:eggbrella/core/render/scene_renderer.dart';
import 'package:eggbrella/core/router/route_paths.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:eggbrella/core/widgets/app_buttons.dart';
import 'package:eggbrella/core/widgets/app_design_frame.dart';
import 'package:eggbrella/core/widgets/app_hud.dart';
import 'package:eggbrella/core/widgets/app_modal_card.dart';
import 'package:eggbrella/core/widgets/app_motion.dart';
import 'package:eggbrella/core/widgets/app_yumi.dart';
import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:eggbrella/generated/locale_keys.g.dart';
import 'package:eggbrella/presentation/game/bloc/game_bloc.dart';
import 'package:eggbrella/presentation/game/bloc/game_event.dart';
import 'package:eggbrella/presentation/game/bloc/game_state.dart';
import 'package:eggbrella/presentation/game/controller/game_world_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/game_view_mixin.dart';
part 'widgets/game_continue_card.dart';
part 'widgets/game_countdown_overlay.dart';
part 'widgets/game_exit_card.dart';
part 'widgets/game_hint_card.dart';
part 'widgets/game_hud.dart';
part 'widgets/game_pause_card.dart';
part 'widgets/game_ready_overlay.dart';
part 'widgets/game_world_layer.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with TickerProviderStateMixin, GameViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.colorSky,
      body: BlocConsumer<GameBloc, GameState>(
        listener: onStateChanged,
        builder: (context, state) {
          final world = worldController;
          if (state.phase == GamePhase.loading || world == null) {
            return Assets.images.imgBgGameStart.image(fit: BoxFit.cover);
          }
          final crashed =
              state.phase == GamePhase.crashed ||
              state.phase == GamePhase.continueOffer;
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: onPointerDown,
            onPointerUp: onPointerUp,
            onPointerCancel: onPointerUp,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Kırılınca dünya donar; yumurta çarptığı yerde kırılır.
                GameWorldLayer(controller: world),
                // Dokunma katmanı HUD'un altında: Pause butonu çalışsın.
                ..._underHud(state),
                AppScreenPadding(
                  child: GameHud(
                    controller: world,
                    coins: state.displayedCoins,
                    showTopRow: !crashed,
                    onPauseTapped: onPauseTapped,
                    onUiPointerDown: onUiPointerDown,
                  ),
                ),
                ..._overlay(state),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _underHud(GameState state) => switch (state.phase) {
    GamePhase.ready => [GameReadyOverlay(onTap: onScreenTapped)],
    GamePhase.hint => [
      GameReadyOverlay(
        onTap: onScreenTapped,
        hint: GameHintCard(mode: controlMode),
      ),
    ],
    _ => const [],
  };

  List<Widget> _overlay(GameState state) {
    return switch (state.phase) {
      GamePhase.countdown => [
        GameCountdownOverlay(seconds: state.secondsLeft),
      ],
      GamePhase.continueOffer => [
        GameContinueCard(
          secondsLeft: state.secondsLeft,
          price: state.continuePrice,
          canAfford: state.canAffordContinue,
          onContinue: onContinueTapped,
          onDecline: onDeclineTapped,
        ),
      ],
      GamePhase.paused => [
        const AppScrim(),
        GamePauseCard(
          floor: state.floor,
          onResume: onResumeTapped,
          onSettings: onSettingsTapped,
          onHome: onExitTapped,
        ),
      ],
      GamePhase.exitConfirm => [
        const AppScrim(),
        GameExitCard(
          floor: state.floor,
          onStay: onExitCancelled,
          onLeave: onExitConfirmed,
        ),
      ],
      _ => const [],
    };
  }
}
