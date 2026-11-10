import 'package:dio/dio.dart';
import 'package:eggbrella/core/managers/auth_cache_manager.dart';
import 'package:eggbrella/data/model/token/token.dart';

/// 401 -> refresh -> retry.
///
/// Döngüsel bağımlılık olmaması için AuthRepository yerine ayrı bir
/// `refreshDio` kullanılır (Dio -> AuthRepository -> NetworkManager -> Dio).
class ExpiredTokenInterceptor extends Interceptor {
  ExpiredTokenInterceptor(this._authCacheManager, this._refreshDio);

  final AuthCacheManager _authCacheManager;
  final Dio _refreshDio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final refreshToken = await _authCacheManager.getRefreshToken();
    if (refreshToken == null) return handler.next(err);

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) return handler.next(err);

      final token = Token.fromJson(data);
      await _authCacheManager.saveToken(token);

      final retry = err.requestOptions
        ..headers['Authorization'] = 'Bearer ${token.accessToken}';
      final result = await _refreshDio.fetch<dynamic>(retry);
      return handler.resolve(result);
    } on DioException {
      await _authCacheManager.clearAll();
      return handler.next(err);
    }
  }
}
