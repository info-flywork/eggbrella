import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/router/route_paths.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/widgets/app_buttons.dart';
import 'package:eggbrella/core/widgets/app_design_frame.dart';
import 'package:eggbrella/core/widgets/app_hud.dart';
import 'package:eggbrella/core/widgets/app_motion.dart';
import 'package:eggbrella/core/widgets/app_yumi.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/locale_keys.g.dart';
import 'package:eggbrella/presentation/home/bloc/home_bloc.dart';
import 'package:eggbrella/presentation/home/bloc/home_event.dart';
import 'package:eggbrella/presentation/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/home_view_mixin.dart';
part 'widgets/home_loaded_body.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with HomeViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => HomeLoadedBody(
          bestFloor: switch (state) {
            HomeInitial() => 0,
            HomeLoaded(:final bestFloor) => bestFloor,
          },
          onPlayTapped: onPlayTapped,
          onSettingsTapped: onSettingsTapped,
          onSkinsTapped: onSkinsTapped,
        ),
      ),
    );
  }
}
