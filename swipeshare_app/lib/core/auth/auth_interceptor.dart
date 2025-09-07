import 'package:dio/dio.dart';
import 'package:swipeshare_app/services/auth/auth_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final AuthService _authService;

  AuthInterceptor({AuthService? authService, Dio? dio})
    : _authService = authService ?? AuthService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await _authService.refreshToken();

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';

      final response = await _authService.dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      await _authService.logout();
      handler.reject(err);
    }
  }
}