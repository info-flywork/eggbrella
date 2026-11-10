import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Figma 01-01-splash: "flywork" daktilo yazısı.
final class SplashBrand extends SplashState {
  const SplashBrand();
}

/// Figma acilis: logo, Yumi ve yükleme çubuğu.
final class SplashLoading extends SplashState {
  const SplashLoading({required this.progress});

  /// 0..1
  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class SplashFinished extends SplashState {
  const SplashFinished();
}
