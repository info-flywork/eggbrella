// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceLoginResponse _$DeviceLoginResponseFromJson(Map<String, dynamic> json) =>
    DeviceLoginResponse(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeviceLoginResponseToJson(
  DeviceLoginResponse instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'user': instance.user?.toJson(),
};
