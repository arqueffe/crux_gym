import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';
import '../services/js_auth_service.dart';

class AuthService {
  // WordPress API endpoint (same-origin)
  static const String baseUrl = JSAuthService.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  String? _token;
  User? _currentUser;

  // Getters
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Initialize auth service
  Future<void> initialize() async {
    print('🚀 Initializing AuthService with JavaScript interop');

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      print('📁 Loaded cached user: ${_currentUser?.username}');
    }

    // Try JavaScript authentication for WordPress cookies
    try {
      print('🌐 Attempting JavaScript cookie authentication...');
      Map<String, dynamic>? jsUserResponse =
          await JSAuthService.getCurrentUser();
      if (jsUserResponse != null) {
        print('🔍 Received JS response: $jsUserResponse');

        // Handle different response formats - check for nested user object
        dynamic responseData = jsUserResponse['data'];
        Map<String, dynamic>? parsedData;

        // If data is a string, parse it as JSON
        if (responseData is String) {
          try {
            parsedData = json.decode(responseData) as Map<String, dynamic>;
            print('📝 Parsed JSON string data');
          } catch (e) {
            print('❌ Failed to parse JSON string: $e');
            parsedData = null;
          }
        } else if (responseData is Map<String, dynamic>) {
          parsedData = responseData;
          print('📦 Data already parsed as Map');
        }

        Map<String, dynamic>? userData;
        if (parsedData != null) {
          if (parsedData['user'] != null) {
            userData = parsedData['user'] as Map<String, dynamic>;
            print('📦 Found user data in nested "user" object');
          } else if (parsedData['id'] != null) {
            userData = parsedData;
            print('📦 Found user data at top level');
          }
        }

        if (userData != null && userData['id'] != null) {
          _currentUser = User.fromJson(userData);

          // Save to local storage
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

          print(
              '✅ JavaScript authentication successful: ${_currentUser?.username}');
          return;
        } else {
          print('❌ No valid user data found in JS response');
        }
      } else {
        print('❌ JavaScript authentication failed - null response');
      }
    } catch (e) {
      print('❌ JavaScript authentication error: $e');
    }

    // Fallback: check if we have a valid cached user
    if (_currentUser == null) {
      print('❌ No valid authentication found');
      await _clearAuth();
    }
  }

  // Check authentication status
  Future<bool> checkAuth() async {
    if (_currentUser != null) {
      return true;
    }

    // Try to refresh authentication
    try {
      final jsUserResponse = await JSAuthService.getCurrentUser();
      if (jsUserResponse != null) {
        // Handle different response formats - check for nested user object
        dynamic responseData = jsUserResponse['data'];
        Map<String, dynamic>? parsedData;

        // If data is a string, parse it as JSON
        if (responseData is String) {
          try {
            parsedData = json.decode(responseData) as Map<String, dynamic>;
          } catch (e) {
            print('❌ Failed to parse JSON string in checkAuth: $e');
            parsedData = null;
          }
        } else if (responseData is Map<String, dynamic>) {
          parsedData = responseData;
        }

        Map<String, dynamic>? userData;
        if (parsedData != null) {
          if (parsedData['user'] != null) {
            userData = parsedData['user'] as Map<String, dynamic>;
          } else if (parsedData['id'] != null) {
            userData = parsedData;
          }
        }

        if (userData != null && userData['id'] != null) {
          _currentUser = User.fromJson(userData);

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

          return true;
        }
      }
    } catch (e) {
      print('❌ Auth check error: $e');
    }

    return false;
  }

  // Get current user from server
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('🔍 Getting current user via JavaScript interop...');

      final response = await JSAuthService.getCurrentUser();
      if (response != null) {
        // Handle different response formats - check for nested user object
        dynamic responseData = response['data'];
        Map<String, dynamic>? parsedData;

        // If data is a string, parse it as JSON
        if (responseData is String) {
          try {
            parsedData = json.decode(responseData) as Map<String, dynamic>;
          } catch (e) {
            print('❌ Failed to parse JSON string in getCurrentUser: $e');
            parsedData = null;
          }
        } else if (responseData is Map<String, dynamic>) {
          parsedData = responseData;
        }

        Map<String, dynamic>? userData;
        if (parsedData != null) {
          if (parsedData['user'] != null) {
            userData = parsedData['user'] as Map<String, dynamic>;
          } else if (parsedData['id'] != null) {
            userData = parsedData;
          }
        }

        if (userData != null && userData['id'] != null) {
          _currentUser = User.fromJson(userData);
          await _saveUserData(userData);
          return {'success': true, 'user': _currentUser};
        }
      }

      // If we get here, authentication failed
      await _clearAuth();
      return {'success': false, 'message': 'Not authenticated'};
    } catch (e) {
      print('❌ Get current user error: $e');
      return {'success': false, 'message': 'Authentication error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateNickname(String nickname) async {
    try {
      print('🔄 Updating nickname via JavaScript interop...');

      final response = await JSAuthService.makeJSRequest(
        '$baseUrl/user/nickname',
        method: 'PUT',
        body: {'nickname': nickname},
      );

      print('📨 Nickname update response: $response');

      // Check for success in different possible response structures
      bool isSuccessful = false;
      String? message;

      if (response != null) {
        // Check if success is at top level
        if (response['success'] == true) {
          isSuccessful = true;
          message = response['message'] ?? response['data']?['message'];
        }
        // Check if success is in data object
        else if (response['data'] != null &&
            response['data']['success'] == true) {
          isSuccessful = true;
          message = response['data']['message'];
        }
        // Check if we have a 200 status with data
        else if (response.containsKey('nickname') ||
            (response['data'] != null &&
                response['data'].containsKey('nickname'))) {
          isSuccessful = true;
          message = 'Nickname updated successfully';
        }
      }

      if (isSuccessful) {
        // Update current user locally
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(nickname: nickname);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
          print('✅ Updated local user data with new nickname: $nickname');
        }

        return {
          'success': true,
          'message': message ?? 'Nickname updated successfully'
        };
      }

      final errorMessage = response?['message'] ??
          response?['data']?['message'] ??
          'Failed to update nickname';

      print('❌ Nickname update failed: $errorMessage');
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('❌ Update nickname error: $e');
      return {'success': false, 'message': 'Update error: $e'};
    }
  }

  // Get headers with authorization (for cookie-based auth, headers are simpler)
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      // For cookie-based auth, we don't need to include tokens in headers
      // The cookies are sent automatically by the browser
    };
  }

  // Private methods
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }

  // Clear authentication data
  Future<void> _clearAuth() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
