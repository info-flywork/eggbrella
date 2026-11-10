import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:eggbrella/data/model/user/user.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_login_response.g.dart';

/// POST /auth/device cevabı.
@JsonSerializable()
class DeviceLoginResponse extends Equatable
    implements BaseModel<DeviceLoginResponse> {
  const DeviceLoginResponse({this.accessToken, this.refreshToken, this.user});

  factory DeviceLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceLoginResponseFromJson(json);

  final String? accessToken;
  final String? refreshToken;
  final User? user;

  @override
  DeviceLoginResponse fromJson(Map<String, dynamic> json) =>
      DeviceLoginResponse.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DeviceLoginResponseToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
