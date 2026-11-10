part of '../home_view.dart';

mixin HomeViewMixin on State<HomeView> {
  HomeBloc get _bloc => context.read<HomeBloc>();

  void onPlayTapped() => context.go(RoutePaths.game.path);

  void onSkinsTapped() =>
      unawaited(context.pushNamed<void>(RoutePaths.store.name));

  Future<void> onSettingsTapped() async {
    await context.pushNamed<void>(RoutePaths.settings.name);
    if (!mounted) return;
    _bloc.add(const HomeRefreshed());
  }
}
