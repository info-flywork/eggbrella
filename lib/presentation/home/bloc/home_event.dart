import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Ayarlardan dönüşte sessiz yenileme.
final class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
