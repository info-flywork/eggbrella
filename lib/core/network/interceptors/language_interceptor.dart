import 'dart:ui';

import 'package:dio/dio.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['Accept-Language'] =
        PlatformDispatcher.instance.locale.languageCode;
    handler.next(options);
  }
}
