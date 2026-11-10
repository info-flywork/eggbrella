import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:eggbrella/data/model/player/player_progress.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchase_sync_response.g.dart';

/// POST /purchases/sync cevabı: RevenueCat işlemleri sunucuda yüklendikten
/// sonraki ilerleme ve bu çağrıda yüklenen coin.
@JsonSerializable()
class PurchaseSyncResponse extends Equatable
    implements BaseModel<PurchaseSyncResponse> {
  const PurchaseSyncResponse({required this.progress, this.creditedCoins = 0});

  factory PurchaseSyncResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseSyncResponseFromJson(json);

  final PlayerProgress progress;
  final int creditedCoins;

  @override
  PurchaseSyncResponse fromJson(Map<String, dynamic> json) =>
      PurchaseSyncResponse.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PurchaseSyncResponseToJson(this);

  @override
  List<Object?> get props => [progress, creditedCoins];
}
