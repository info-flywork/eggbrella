import 'package:eggbrella/core/router/route_paths.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/widgets/app_hud.dart';
import 'package:eggbrella/core/widgets/app_motion.dart';
import 'package:eggbrella/core/widgets/app_yumi.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_bloc.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/splash_view_mixin.dart';
part 'widgets/splash_brand_body.dart';
part 'widgets/splash_loading_body.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SplashViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      listener: onStateChanged,
      builder: (context, state) {
        // Material: metin varsayılan stili (yoksa Flutter metnin altına
        // sarı hata çizgisi çizer).
        return Material(
          color: ColorName.colorBrandGreen,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: switch (state) {
              SplashBrand() => const SplashBrandBody(),
              SplashLoading(:final progress) => SplashLoadingBody(
                progress: progress,
              ),
              SplashFinished() => const SplashLoadingBody(progress: 1),
            },
          ),
        );
      },
    );
  }
}
