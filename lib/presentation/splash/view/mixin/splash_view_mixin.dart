part of '../splash_view.dart';

mixin SplashViewMixin on State<SplashView> {
  void onStateChanged(BuildContext context, SplashState state) {
    if (state is SplashFinished) context.go(RoutePaths.home.path);
  }
}
