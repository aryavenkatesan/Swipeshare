import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class WebTokenStorage implements TokenStorage {
  String? _localAccessToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _localAccessToken = accessToken;
    // refreshToken is stored in http only cookie, so no need to store it here
  }

  @override
  Future<String?> getAccessToken() async {
    return _localAccessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    return null;
  }

  @override
  Future<void> clearTokens() async {
    _localAccessToken = null;
  }
}

class MobileTokenStorage implements TokenStorage {
  static const String _accessTokenFieldName = 'accessToken';
  static const String _refreshTokenFieldName = 'refreshToken';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final futures = <Future<void>>[
      _secureStorage.write(key: _accessTokenFieldName, value: accessToken),
    ];

    if (refreshToken != null) {
      futures.add(
        _secureStorage.write(key: _refreshTokenFieldName, value: refreshToken),
      );
    }

    try {
      await Future.wait(futures);
    } catch (e) {
      debugPrint('Error saving tokens: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenFieldName);
    } catch (e) {
      debugPrint('Error reading access token: $e');
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenFieldName);
    } catch (e) {
      debugPrint('Error reading refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenFieldName),
        _secureStorage.delete(key: _refreshTokenFieldName),
      ]);
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
      rethrow;
    }
  }
}

final _webTokenStorage = WebTokenStorage();
final _mobileTokenStorage = MobileTokenStorage();

TokenStorage getTokenStorage() {
  if (kIsWeb) {
    return _webTokenStorage;
  } else {
    return _mobileTokenStorage;
  }
}
