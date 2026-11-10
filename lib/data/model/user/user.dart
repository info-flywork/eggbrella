import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable implements BaseModel<User> {
  const User({this.id, this.name, this.email, this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final String? id;
  final String? name;
  final String? email;
  final String? avatarUrl;

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}
