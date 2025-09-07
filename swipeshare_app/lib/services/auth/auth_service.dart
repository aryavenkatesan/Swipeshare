import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/core/auth/token_storage.dart';
import 'package:swipeshare_app/core/network/auth_client.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio;
  final TokenStorage _tokenStorageService;
  bool _isAuthenticated = false;

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService.newInstance({Dio? dio, TokenStorage? tokenStorageService})
    : _dio = dio ?? authClient,
      _tokenStorageService = tokenStorageService ?? getTokenStorage();

  AuthService._internal()
    : _dio = authClient,
      _tokenStorageService = getTokenStorage();

  bool get isAuthenticated => _isAuthenticated;
  Dio get dio => _dio;

  Future<void> initializeAuthState() async {
    final accessToken = await _tokenStorageService.getAccessToken();
    if (accessToken != null) {
      // Token exists, assume user is authenticated
      // You might want to validate the token here by making a test API call
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      debugPrint("response data: ${response.data}");

      debugPrint("accessToken $accessToken");
      debugPrint("refreshToken $refreshToken");

      await _tokenStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await _tokenStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _tokenStorageService.clearTokens();
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<String> refreshToken() async {
    try {
      final refreshToken = await _tokenStorageService.getRefreshToken();
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'];
      _tokenStorageService.saveTokens(accessToken: newAccessToken);

      _isAuthenticated = true;
      notifyListeners();
      return newAccessToken;
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    return await _tokenStorageService.getAccessToken();
  }
}
