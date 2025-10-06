import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_models.dart';
import '../services/js_auth_service.dart';

class AuthService {
  // WordPress API endpoint (same-origin)
  static const String baseUrl = '/crux-climbing-gym/wp-json/crux/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  String? _token;
  User? _currentUser;

  // Getters
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _token != null;

  // Initialize auth service
  Future<void> initialize() async {
    print('🚀 Initializing AuthService');

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      print('📁 Loaded cached user: ${_currentUser?.username}');
    }

    // If we have a JWT token, validate it
    if (_token != null) {
      print('🔑 Found JWT token, validating...');
      final isValid = await _validateToken();
      if (isValid) {
        print('✅ JWT token is valid');
        return;
      } else {
        print('❌ JWT token is invalid, clearing auth');
        await _clearAuth();
      }
    }

    // Fallback: Try JavaScript authentication for WordPress cookies (legacy support)
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

    // If we get here, no valid authentication found
    if (_currentUser == null) {
      print('❌ No valid authentication found');
      await _clearAuth();
    }
  }

  // Validate JWT token
  Future<bool> _validateToken() async {
    if (_token == null) {
      return false;
    }

    try {
      final response = await JSAuthService.makeJSRequest(
        '$baseUrl/auth/validate',
        method: 'GET',
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response != null && response['success'] == true) {
        final userData = response['user'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);

          // Update cached user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

          return true;
        }
      }
    } catch (e) {
      print('❌ Token validation error: $e');
    }

    return false;
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

  // Register new user with JWT authentication
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      print('🚀 Registering user: $username');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      print('📨 Register response status: ${response.statusCode}');
      print('📨 Register response body: ${response.body}');

      if (response.statusCode != 200) {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            print('❌ Registration error: ${errorData['message']}');
            return {'success': false, 'message': errorData['message']};
          }
        } catch (e) {
          // Couldn't parse error
        }
        print('❌ Registration failed with status ${response.statusCode}');
        return {'success': false, 'message': 'Registration failed'};
      }

      final responseData = jsonDecode(response.body);

      // Check for WordPress REST API errors (have 'code' and 'message')
      if (responseData.containsKey('code') &&
          responseData.containsKey('message')) {
        final errorMessage = responseData['message'] ?? 'Registration failed';
        print('❌ Registration error: ${responseData['code']} - $errorMessage');
        return {'success': false, 'message': errorMessage};
      }

      // Check for successful registration
      if (responseData['success'] == true) {
        final token = responseData['token'];
        final userData = responseData['user'];

        if (token != null && userData != null) {
          _token = token;
          _currentUser = User.fromJson(userData);

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, _token!);
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

          print('✅ Registration successful: ${_currentUser?.username}');
          return {
            'success': true,
            'message': responseData['message'] ?? 'Registration successful'
          };
        }
      }

      // Unknown response format
      final errorMessage = responseData['message'] ?? 'Registration failed';
      print('❌ Registration failed: $errorMessage');
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('❌ Registration error: $e');
      return {'success': false, 'message': 'Registration error: $e'};
    }
  }

  // Login user with JWT authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🚀 Logging in user: $username');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📨 Login response status: ${response.statusCode}');
      print('📨 Login response body: ${response.body}');

      if (response.statusCode != 200) {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            print('❌ Login error: ${errorData['message']}');
            return {'success': false, 'message': errorData['message']};
          }
        } catch (e) {
          // Couldn't parse error
        }
        print('❌ Login failed with status ${response.statusCode}');
        return {'success': false, 'message': 'Login failed'};
      }

      final responseData = jsonDecode(response.body);

      // Check for WordPress REST API errors (have 'code' and 'message')
      if (responseData.containsKey('code') &&
          responseData.containsKey('message')) {
        final errorMessage = responseData['message'] ?? 'Login failed';
        print('❌ Login error: ${responseData['code']} - $errorMessage');
        return {'success': false, 'message': errorMessage};
      }

      // Check for successful login
      if (responseData['success'] == true) {
        final token = responseData['token'];
        final userData = responseData['user'];

        if (token != null && userData != null) {
          _token = token;
          _currentUser = User.fromJson(userData);

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, _token!);
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

          print('✅ Login successful: ${_currentUser?.username}');
          return {
            'success': true,
            'message': responseData['message'] ?? 'Login successful'
          };
        }
      }

      // Unknown response format
      final errorMessage =
          responseData['message'] ?? 'Invalid username or password';
      print('❌ Login failed: $errorMessage');
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  // Logout user
  Future<void> logout() async {
    print('🚪 Logging out user');
    await _clearAuth();
  }

  // Get headers with authorization (JWT token)
  Map<String, String> getAuthHeaders() {
    if (_token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };
    }
    return {
      'Content-Type': 'application/json',
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
