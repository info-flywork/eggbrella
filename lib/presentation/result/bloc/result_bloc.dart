import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:eggbrella/domain/clip/clip_repository.dart';
import 'package:eggbrella/generated/locale_keys.g.dart';
import 'package:eggbrella/presentation/result/bloc/result_event.dart';
import 'package:eggbrella/presentation/result/bloc/result_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Oyun sonu: skor / rekor ve klip üretip paylaşma.
class ResultBloc extends Bloc<ResultEvent, ResultState> {
  ResultBloc(GameResult result, this._clips, SoundManager sound)
    : super(ResultState(result: result)) {
    on<ResultShareTapped>(_onShareTapped);
    on<ResultClipDismissed>(_onDismissed);
    on<ResultShareClosed>(_onShareClosed);
    if (result.isNewRecord) sound.play(GameSound.fanfare);
  }

  final ClipRepository _clips;

  /// "Vazgeç" sonrası geç gelen sonucu yok saymak için.
  int _attempt = 0;

  Future<void> _onShareTapped(
    ResultShareTapped event,
    Emitter<ResultState> emit,
  ) async {
    final replay = state.result.replay;
    if (replay == null || state.clipStatus == ClipStatus.preparing) return;
    if (state.clip != null) {
      emit(state.copyWith(clipStatus: ClipStatus.sharing));
      return;
    }
    final attempt = ++_attempt;
    emit(state.copyWith(clipStatus: ClipStatus.preparing));
    try {
      final clip = await _clips.create(
        replay: replay,
        floorLabel: (floor) => LocaleKeys.common_floor.tr(args: ['$floor']),
      );
      if (attempt != _attempt) return;
      emit(state.copyWith(clipStatus: ClipStatus.sharing, clip: clip));
    } on Object catch (e) {
      debugPrint('ResultBloc: klip üretilemedi: $e');
      if (attempt != _attempt) return;
      emit(state.copyWith(clipStatus: ClipStatus.error));
    }
  }

  void _onDismissed(ResultClipDismissed event, Emitter<ResultState> emit) {
    _attempt++;
    emit(state.copyWith(clipStatus: ClipStatus.idle));
  }

  void _onShareClosed(ResultShareClosed event, Emitter<ResultState> emit) =>
      emit(state.copyWith(clipStatus: ClipStatus.idle));
}
