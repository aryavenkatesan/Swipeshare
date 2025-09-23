import 'package:swipeshare_app/providers/util/async_provider.dart';
import 'package:swipeshare_app/services/auth/auth_service.dart';

class AuthProvider extends AsyncProvider {
  final AuthService authService;
  bool _isAuthenticated = false;

  AuthProvider({AuthService? authService})
    : authService = authService ?? AuthService() {
    ensureInitialized();
  }

  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> initialize() async {
    try {
      await authService.refreshToken();
      _isAuthenticated = true;
    } catch (e) {
      await authService.logout();
      _isAuthenticated = false;
    }
  }

  @override
  Future<void> reset() async {
    await authService.logout();
    _isAuthenticated = false;
  }

  Future<void> login(String email, String password) {
    return executeOperation(() async {
      try {
        await authService.login(email, password);
        _isAuthenticated = true;
      } catch (e) {
        _isAuthenticated = false;
        rethrow;
      }
    });
  }

  Future<void> register(String email, String password) {
    return executeOperation(() async {
      try {
        await authService.register(email, password);
        _isAuthenticated = true;
      } catch (e) {
        _isAuthenticated = false;
        rethrow;
      }
    });
  }

  Future<void> logout() {
    return executeOperation(() async {
      try {
        await authService.logout();
      } finally {
        _isAuthenticated = false;
      }
    });
  }

  Future<String> refreshToken() {
    return executeOperation(() async {
      try {
        final newAccessToken = await authService.refreshToken();
        _isAuthenticated = true;
        return newAccessToken;
      } catch (e) {
        _isAuthenticated = false;
        rethrow;
      }
    });
  }
}
