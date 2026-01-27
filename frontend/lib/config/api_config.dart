import 'package:flutter/foundation.dart';

/// API configuration for the Crux Climbing Gym app
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// WordPress API endpoint for web platform (same-origin)
  static const String wordPressApiPath = '/crux-climbing-gym/wp-json/crux/v1';

  /// Fallback URL for non-web platforms (Python backend)
  static const String fallbackApiUrl = 'http://localhost:5000/api';

  /// Full WordPress API URL (for non-web platforms that need absolute URL)
  static const String wordPressApiUrl = 'http://cruxclub.fr/wp-json/crux/v1';

  /// Get the appropriate base URL based on platform
  static String get baseUrl => kIsWeb ? wordPressApiPath : fallbackApiUrl;

  /// Get the full WordPress API URL (useful for role service, etc.)
  static String get fullWordPressUrl => wordPressApiUrl;
}
