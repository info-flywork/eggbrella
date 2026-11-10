// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerProgress _$PlayerProgressFromJson(Map<String, dynamic> json) =>
    PlayerProgress(
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      bestFloor: (json['best_floor'] as num?)?.toInt() ?? 0,
      gamesPlayed: (json['games_played'] as num?)?.toInt() ?? 0,
      continuePrice: (json['continue_price'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$PlayerProgressToJson(PlayerProgress instance) =>
    <String, dynamic>{
      'coins': instance.coins,
      'best_floor': instance.bestFloor,
      'games_played': instance.gamesPlayed,
      'continue_price': instance.continuePrice,
    };
