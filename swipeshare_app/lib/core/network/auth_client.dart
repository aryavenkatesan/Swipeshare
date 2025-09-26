import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:swipeshare_app/core/config/environment.dart';
import 'package:swipeshare_app/core/network/interceptor/platform_interceptor.dart';

/// An unauthenticated API client used for authorization concerns
/// like login, registration, and token refresh
final authClient = Dio(
  BaseOptions(
    baseUrl: '${EnvironmentConfig.apiBaseUrl}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    extra: kIsWeb ? {'withCredentials': true} : {},
  ),
)..interceptors.add(PlatformInterceptor());
