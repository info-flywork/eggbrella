import 'package:dio/dio.dart';
import 'package:eggbrella/core/managers/auth_cache_manager.dart';
import 'package:eggbrella/core/network/interceptors/auth_interceptor.dart';
import 'package:eggbrella/core/network/interceptors/expired_token_interceptor.dart';
import 'package:eggbrella/core/network/interceptors/language_interceptor.dart';
import 'package:eggbrella/core/utils/constants/string_constants.dart';
import 'package:flutter/foundation.dart';

abstract final class DioClient {
  static BaseOptions get _options => BaseOptions(
    baseUrl: StringConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  );

  static Dio create({required AuthCacheManager authCacheManager}) {
    final dio = Dio(_options);
    dio.interceptors.addAll([
      LanguageInterceptor(),
      AuthInterceptor(authCacheManager),
      ExpiredTokenInterceptor(authCacheManager, Dio(_options)),
      if (kDebugMode) LogInterceptor(requestBody: true),
    ]);
    return dio;
  }
}
