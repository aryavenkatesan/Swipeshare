import 'package:dio/dio.dart';
import 'package:swipeshare_app/services/token_storage.dart';
import 'package:swipeshare_app/core/network/auth_client.dart';
import 'package:swipeshare_app/models/auth.dart';

class AuthService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthService({Dio? dio, TokenStorage? tokenStorage})
    : _dio = dio ?? authClient,
      _tokenStorage = tokenStorage ?? getTokenStorage();

  Dio get dio => _dio;

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final accessToken = response.data['access_token'] as String;
    final refreshToken = response.data['refresh_token'] as String?;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: User.fromJson(response.data['user']),
    );
  }

  Future<AuthResponse> register(String email, String password) async {
    final response = await _dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );

    final accessToken = response.data['access_token'] as String;
    final refreshToken = response.data['refresh_token'] as String?;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: User.fromJson(response.data['user']),
    );
  }

  Future<String> refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final newAccessToken = response.data['access_token'];
    _tokenStorage.saveTokens(accessToken: newAccessToken);

    return newAccessToken;
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }
}
