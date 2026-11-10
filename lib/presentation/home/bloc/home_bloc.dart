import 'dart:async';

import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/presentation/home/bloc/home_event.dart';
import 'package:eggbrella/presentation/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._player, this._sound) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
  }

  final PlayerRepository _player;
  final SoundManager _sound;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    _sound.startMusic();
    emit(HomeLoaded(bestFloor: _player.progress.bestFloor));
    // Bekleyen olayları gönder; sunucuda daha yüksek rekor varsa göster.
    final progress = await _player.refresh();
    emit(HomeLoaded(bestFloor: progress.bestFloor));
  }

  void _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) =>
      emit(HomeLoaded(bestFloor: _player.progress.bestFloor));
}
