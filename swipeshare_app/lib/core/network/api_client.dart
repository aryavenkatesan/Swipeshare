import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:swipeshare_app/core/config/environment.dart';
import 'package:swipeshare_app/core/network/interceptor/auth_interceptor.dart';
import 'package:swipeshare_app/core/network/interceptor/platform_interceptor.dart';

/// An authenticated API client used for most network requests throughout the app,
final apiClient = Dio(
  BaseOptions(
    baseUrl: '${EnvironmentConfig.apiBaseUrl}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    extra: kIsWeb ? {'withCredentials': true} : {},
  ),
)..interceptors.addAll([PlatformInterceptor(), AuthInterceptor()]);
