import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// An API interceptor that adds platform-specific headers to requests.
class PlatformInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Client-Type'] = kIsWeb ? 'web' : 'mobile';
    super.onRequest(options, handler);
  }
}