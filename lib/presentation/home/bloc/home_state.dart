import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({required this.bestFloor});

  /// Figma: "Rekor: N. kat" (yerel kayıt; ilk oyunda 0).
  final int bestFloor;

  @override
  List<Object?> get props => [bestFloor];
}
