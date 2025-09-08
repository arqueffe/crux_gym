import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../models/user_models.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final CacheService _cacheService = CacheService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.isAuthenticated;
  User? get currentUser => _authService.currentUser;
  String? get token => _authService.token;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      if (_authService.isAuthenticated) {
        await _authService.getCurrentUser();
      }
    } catch (e) {
      _setError('Initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Register a new user
  Future<bool> register({
    required String username,
    required String nickname,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        username: username,
        nickname: nickname,
        email: email,
        password: password,
      );

      if (result['success']) {
        // Clear any cached data
        _cacheService.clear();
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );

      if (result['success']) {
        // Clear any cached data from previous user
        _cacheService.invalidateUserData();
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      // Clear all cached data on logout
      _cacheService.clear();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh current user data
  Future<void> refreshUser() async {
    if (!_authService.isAuthenticated) return;

    try {
      await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh user data: $e');
    }
  }

  // Get auth headers for API calls
  Map<String, String> getAuthHeaders() {
    return _authService.getAuthHeaders();
  }

  // Update user nickname
  Future<bool> updateNickname(String nickname) async {
    try {
      final result = await _authService.updateNickname(nickname);
      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to update nickname');
        return false;
      }
    } catch (e) {
      _setError('Failed to update nickname: $e');
      return false;
    }
  }

  // Check if user has permission to create routes
  bool get canCreateRoutes {
    return currentUser?.canCreateRoutes ?? false;
  }

  // Check if user is an admin
  bool get isAdmin {
    return currentUser?.isAdmin ?? false;
  }

  // Check if user is a route setter
  bool get isRouteSetter {
    return currentUser?.isRouteSetter ?? false;
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
