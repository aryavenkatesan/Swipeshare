import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:swipeshare_app/core/auth/auth_interceptor.dart';
import 'package:swipeshare_app/core/network/platform_interceptor.dart';

final apiClient = Dio(
  BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    extra: kIsWeb ? {'withCredentials': true} : {},
  ),
)..interceptors.addAll([PlatformInterceptor(), AuthInterceptor()]);
