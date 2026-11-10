import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';

/// API sarmalayıcı: `{ "status": "...", "message": "...", "data": {...} }`
class BaseResponse<T extends BaseModel<T>> extends Equatable {
  const BaseResponse({this.status, this.message, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parserModel,
  ) {
    final data = json['data'];
    return BaseResponse<T>(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: data is Map<String, dynamic> ? parserModel(data) : null,
    );
  }

  final String? status;
  final String? message;
  final T? data;

  bool get isSuccess => status == 'success';

  @override
  List<Object?> get props => [status, message, data];
}
