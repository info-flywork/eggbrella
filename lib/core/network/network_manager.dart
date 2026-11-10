import 'package:dio/dio.dart';
import 'package:eggbrella/core/base/model/base_model.dart';
import 'package:eggbrella/core/base/model/base_response.dart';
import 'package:eggbrella/core/network/network_exception.dart';
import 'package:eggbrella/core/utils/enum/request_type.dart';

class NetworkManager {
  NetworkManager(this._dio);

  final Dio _dio;

  Future<T?> send<T extends BaseModel<T>>({
    required String path,
    required RequestType method,
    required T Function(Map<String, dynamic> json) parserModel,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method.value),
      );
      final body = response.data;
      if (body == null) return null;
      final baseResponse = BaseResponse<T>.fromJson(body, parserModel);
      if (!baseResponse.isSuccess) {
        throw NetworkException(
          baseResponse.message ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return baseResponse.data;
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw NetworkException(
        message ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
