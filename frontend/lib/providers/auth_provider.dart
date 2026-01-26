import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_models.dart';

class AuthProvider with ChangeNotifier {
  static String baseUrl = AuthService.baseUrl;
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.isAuthenticated;
  User? get currentUser => _authService.currentUser;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
    } catch (e) {
      _setError('Initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        email: email,
        username: username,
        password: password,
      );

      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Registration failed');
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
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(username, password);

      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Login failed');
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
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check authentication status
  Future<void> checkAuth() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.checkAuth();
      if (!result) {
        _setError('Please log in to WordPress to access the app');
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to check authentication: $e');
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
    _clearError();
    try {
      final result = await _authService.updateNickname(nickname);
      if (result['success'] == true) {
        // Refresh user data from server to ensure UI is up to date
        await refreshUser();
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
