import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clip_upload_response.g.dart';

/// `POST /clips` cevabı: Bunny CDN'deki klibin herkese açık adresi.
@JsonSerializable()
class ClipUploadResponse extends Equatable
    implements BaseModel<ClipUploadResponse> {
  const ClipUploadResponse({this.url});

  factory ClipUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ClipUploadResponseFromJson(json);

  final String? url;

  @override
  ClipUploadResponse fromJson(Map<String, dynamic> json) =>
      ClipUploadResponse.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ClipUploadResponseToJson(this);

  @override
  List<Object?> get props => [url];
}
