import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class to manage environment-specific settings from .env
class EnvironmentConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
}
