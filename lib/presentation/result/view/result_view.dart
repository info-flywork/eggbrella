import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/router/route_paths.dart';
import 'package:eggbrella/core/share/clip_share.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/widgets/app_buttons.dart';
import 'package:eggbrella/core/widgets/app_design_frame.dart';
import 'package:eggbrella/core/widgets/app_hud.dart';
import 'package:eggbrella/core/widgets/app_modal_card.dart';
import 'package:eggbrella/core/widgets/app_motion.dart';
import 'package:eggbrella/core/widgets/app_yumi.dart';
import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:eggbrella/generated/locale_keys.g.dart';
import 'package:eggbrella/presentation/result/bloc/result_bloc.dart';
import 'package:eggbrella/presentation/result/bloc/result_event.dart';
import 'package:eggbrella/presentation/result/bloc/result_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/result_view_mixin.dart';
part 'widgets/result_clip_cards.dart';
part 'widgets/result_confetti.dart';
part 'widgets/result_loaded_body.dart';

class ResultView extends StatefulWidget {
  const ResultView({super.key});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> with ResultViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ResultBloc, ResultState>(
        listener: onStateChanged,
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ResultLoadedBody(
                result: state.result,
                canShareClip: state.canShareClip,
                onPlayAgain: onPlayAgainTapped,
                onShare: onShareTapped,
                onHome: onHomeTapped,
              ),
              if (state.clipStatus == ClipStatus.preparing) ...[
                const AppScrim(),
                ResultClipPreparingCard(onCancel: onClipDismissed),
              ],
              if (state.clipStatus == ClipStatus.error) ...[
                const AppScrim(),
                ResultClipErrorCard(
                  onRetry: onShareTapped,
                  onClose: onClipDismissed,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
