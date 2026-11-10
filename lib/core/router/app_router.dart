import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/router/app_page_transitions.dart';
import 'package:eggbrella/core/router/route_paths.dart';
import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:eggbrella/presentation/game/bloc/game_bloc.dart';
import 'package:eggbrella/presentation/game/bloc/game_event.dart';
import 'package:eggbrella/presentation/game/view/game_view.dart';
import 'package:eggbrella/presentation/home/bloc/home_bloc.dart';
import 'package:eggbrella/presentation/home/bloc/home_event.dart';
import 'package:eggbrella/presentation/home/view/home_view.dart';
import 'package:eggbrella/presentation/result/bloc/result_bloc.dart';
import 'package:eggbrella/presentation/result/view/result_view.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_bloc.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_event.dart';
import 'package:eggbrella/presentation/settings/view/settings_view.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_bloc.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_event.dart';
import 'package:eggbrella/presentation/splash/view/splash_view.dart';
import 'package:eggbrella/presentation/store/bloc/store_bloc.dart';
import 'package:eggbrella/presentation/store/bloc/store_event.dart';
import 'package:eggbrella/presentation/store/view/store_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RoutePaths.splash.path,
  routes: [
    GoRoute(
      path: RoutePaths.splash.path,
      name: RoutePaths.splash.name,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SplashBloc>()..add(const SplashStarted()),
        child: const SplashView(),
      ),
    ),
    GoRoute(
      path: RoutePaths.home.path,
      name: RoutePaths.home.name,
      pageBuilder: (context, state) => AppPageTransitions.fadeScale(
        state,
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
          child: const HomeView(),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.game.path,
      name: RoutePaths.game.name,
      pageBuilder: (context, state) => AppPageTransitions.zoom(
        state,
        BlocProvider(
          create: (_) => getIt<GameBloc>()..add(const GameStarted()),
          child: const GameView(),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.result.path,
      name: RoutePaths.result.name,
      redirect: (context, state) =>
          state.extra is GameResult ? null : RoutePaths.home.path,
      pageBuilder: (context, state) => AppPageTransitions.fadeUp(
        state,
        BlocProvider(
          create: (_) => getIt<ResultBloc>(param1: state.extra! as GameResult),
          child: const ResultView(),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.settings.path,
      name: RoutePaths.settings.name,
      pageBuilder: (context, state) => AppPageTransitions.overlay(
        state,
        BlocProvider(
          create: (_) => getIt<SettingsBloc>()..add(const SettingsStarted()),
          child: const SettingsView(),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.store.path,
      name: RoutePaths.store.name,
      pageBuilder: (context, state) => AppPageTransitions.fadeUp(
        state,
        BlocProvider(
          create: (_) => getIt<StoreBloc>()..add(const StoreStarted()),
          child: const StoreView(),
        ),
      ),
    ),
  ],
);
