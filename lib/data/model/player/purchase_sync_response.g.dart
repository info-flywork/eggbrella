// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_sync_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseSyncResponse _$PurchaseSyncResponseFromJson(
  Map<String, dynamic> json,
) => PurchaseSyncResponse(
  progress: PlayerProgress.fromJson(json['progress'] as Map<String, dynamic>),
  creditedCoins: (json['credited_coins'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PurchaseSyncResponseToJson(
  PurchaseSyncResponse instance,
) => <String, dynamic>{
  'progress': instance.progress.toJson(),
  'credited_coins': instance.creditedCoins,
};
