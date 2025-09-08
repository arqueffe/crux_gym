import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_models.dart';
import '../models/lane_models.dart';
import '../providers/auth_provider.dart';
import 'cache_service.dart';

/// Cached API service that wraps HTTP requests with intelligent caching
class CachedApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final AuthProvider authProvider;
  final CacheService _cacheService = CacheService();

  CachedApiService({required this.authProvider});

  // Get headers with authentication
  Map<String, String> get _headers => authProvider.getAuthHeaders();

  /// Generic cached GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheService.generateKey(endpoint, params);
    final duration = cacheDuration ?? CacheService.defaultCacheDuration;

    // Check cache first unless force refresh is requested
    if (!forceRefresh) {
      final cachedData = _cacheService.get<Map<String, dynamic>>(
        cacheKey,
        maxAge: duration,
      );
      if (cachedData != null) {
        return {
          'success': true,
          'data': cachedData['data'],
          'fromCache': true,
        };
      }
    }

    // Build URL with query parameters
    var uri = Uri.parse('$baseUrl$endpoint');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(
          queryParameters:
              params.map((key, value) => MapEntry(key, value.toString())));
    }

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final responseData = {
          'success': true,
          'data': json.decode(response.body),
          'fromCache': false,
        };

        // Cache the successful response
        _cacheService.put(cacheKey, responseData);

        return responseData;
      } else {
        return {
          'success': false,
          'error': 'Request failed with status ${response.statusCode}',
          'fromCache': false,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
        'fromCache': false,
      };
    }
  }

  /// POST request (not cached, but invalidates related cache)
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    List<String>? invalidatePatterns,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      // Invalidate related cache entries after successful POST
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (invalidatePatterns != null) {
          for (final pattern in invalidatePatterns) {
            _cacheService.invalidatePattern(pattern);
          }
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Request failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// PUT request (not cached, but invalidates related cache)
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    List<String>? invalidatePatterns,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      // Invalidate related cache entries after successful PUT
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (invalidatePatterns != null) {
          for (final pattern in invalidatePatterns) {
            _cacheService.invalidatePattern(pattern);
          }
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Request failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// DELETE request (not cached, but invalidates related cache)
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    List<String>? invalidatePatterns,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      // Invalidate related cache entries after successful DELETE
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (invalidatePatterns != null) {
          for (final pattern in invalidatePatterns) {
            _cacheService.invalidatePattern(pattern);
          }
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': response.body.isNotEmpty ? json.decode(response.body) : {},
        };
      } else {
        return {
          'success': false,
          'error': 'Request failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // High-level API methods with caching

  /// Get routes with caching
  Future<List<Route>> getRoutes({
    String? wallSection,
    String? grade,
    int? lane,
    bool forceRefresh = false,
  }) async {
    final params = <String, dynamic>{};
    if (wallSection != null) params['wall_section'] = wallSection;
    if (grade != null) params['grade'] = grade;
    if (lane != null) params['lane'] = lane;

    final response =
        await get('/routes', params: params, forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Route.fromJson(json)).toList();
    } else {
      throw Exception(response['error'] ?? 'Failed to load routes');
    }
  }

  /// Get single route with caching
  Future<Route> getRoute(int routeId, {bool forceRefresh = false}) async {
    final response = await get('/routes/$routeId', forceRefresh: forceRefresh);

    if (response['success']) {
      return Route.fromJson(response['data']);
    } else {
      throw Exception(response['error'] ?? 'Failed to load route');
    }
  }

  /// Get wall sections with caching
  Future<List<String>> getWallSections({bool forceRefresh = false}) async {
    final response = await get('/wall-sections', forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.cast<String>();
    } else {
      throw Exception(response['error'] ?? 'Failed to load wall sections');
    }
  }

  /// Get grades with caching
  Future<List<String>> getGrades({bool forceRefresh = false}) async {
    final response = await get('/grades', forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.cast<String>();
    } else {
      throw Exception(response['error'] ?? 'Failed to load grades');
    }
  }

  /// Get lanes with caching
  Future<List<Lane>> getLanes({bool forceRefresh = false}) async {
    final response = await get('/lanes', forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Lane.fromJson(json)).toList();
    } else {
      throw Exception(response['error'] ?? 'Failed to load lanes');
    }
  }

  /// Get grade definitions with caching
  Future<List<Map<String, dynamic>>> getGradeDefinitions(
      {bool forceRefresh = false}) async {
    final response =
        await get('/grade-definitions', forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(response['error'] ?? 'Failed to load grade definitions');
    }
  }

  /// Get hold colors with caching
  Future<List<Map<String, dynamic>>> getHoldColors(
      {bool forceRefresh = false}) async {
    final response = await get('/hold-colors', forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(response['error'] ?? 'Failed to load hold colors');
    }
  }

  /// Get grade colors with caching
  Future<Map<String, String>> getGradeColors(
      {bool forceRefresh = false}) async {
    final response = await get('/grade-colors', forceRefresh: forceRefresh);

    if (response['success']) {
      final Map<String, dynamic> data = response['data'];
      return data.cast<String, String>();
    } else {
      throw Exception(response['error'] ?? 'Failed to load grade colors');
    }
  }

  /// Get user ticks with caching
  Future<List<dynamic>> getUserTicks({bool forceRefresh = false}) async {
    final response = await get('/user/ticks', forceRefresh: forceRefresh);

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Failed to load user ticks');
    }
  }

  /// Get user likes with caching
  Future<List<dynamic>> getUserLikes({bool forceRefresh = false}) async {
    final response = await get('/user/likes', forceRefresh: forceRefresh);

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Failed to load user likes');
    }
  }

  /// Get user projects with caching - returns List<Project>
  Future<List<Project>> getUserProjectsTyped(
      {bool forceRefresh = false}) async {
    final response = await get('/user/projects', forceRefresh: forceRefresh);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception(response['error'] ?? 'Failed to load user projects');
    }
  }

  /// Get user projects with caching
  Future<List<dynamic>> getUserProjects({bool forceRefresh = false}) async {
    final response = await get('/user/projects', forceRefresh: forceRefresh);

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Failed to load user projects');
    }
  }

  // Additional API methods needed by RouteProvider

  /// Create a new route
  Future<Route> createRoute(Route route) async {
    final response =
        await post('/routes', route.toJson(), invalidatePatterns: ['/routes']);

    if (response['success']) {
      return Route.fromJson(response['data']);
    } else {
      throw Exception(response['error'] ?? 'Failed to create route');
    }
  }

  /// Get user's tick status for a route
  Future<Map<String, dynamic>> getUserTick(int routeId) async {
    final response = await get('/routes/$routeId/ticks/me');

    if (response['success']) {
      return response['data'] as Map<String, dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Failed to get tick status');
    }
  }

  /// Add attempts to a route (without marking as sent)
  Future<void> addAttempts(int routeId, int attempts, {String? notes}) async {
    final body = {
      'attempts': attempts,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await post('/routes/$routeId/attempts', body,
        invalidatePatterns: ['/user/ticks', '/user/stats', '/routes/$routeId']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to add attempts');
    }
  }

  /// Mark a route as sent in a specific style
  Future<void> markSend(int routeId, String sendType, {String? notes}) async {
    final body = {
      'send_type': sendType,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await post('/routes/$routeId/send', body,
        invalidatePatterns: [
          '/user/ticks',
          '/user/stats',
          '/routes/$routeId',
          '/routes'
        ]);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to mark send');
    }
  }

  /// Add a comment to a route
  Future<void> addComment(int routeId, String content) async {
    final body = {'content': content};

    final response = await post('/routes/$routeId/comments', body,
        invalidatePatterns: ['/routes/$routeId']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to add comment');
    }
  }

  /// Propose a grade for a route
  Future<void> proposeGrade(
      int routeId, String proposedGrade, String reasoning) async {
    final body = {
      'proposed_grade': proposedGrade,
      'reasoning': reasoning,
    };

    final response = await post('/routes/$routeId/grade-proposals', body,
        invalidatePatterns: ['/routes/$routeId']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to propose grade');
    }
  }

  /// Get user's grade proposal for a route
  Future<GradeProposal?> getUserGradeProposal(int routeId) async {
    final response = await get('/routes/$routeId/grade-proposals/me');

    if (response['success']) {
      final data = response['data'];
      return data != null ? GradeProposal.fromJson(data) : null;
    } else {
      throw Exception(response['error'] ?? 'Failed to get grade proposal');
    }
  }

  /// Add a warning to a route
  Future<void> addWarning(
      int routeId, String warningType, String description) async {
    final body = {
      'warning_type': warningType,
      'description': description,
    };

    final response = await post('/routes/$routeId/warnings', body,
        invalidatePatterns: ['/routes/$routeId']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to add warning');
    }
  }

  /// Get project status for a route
  Future<Map<String, dynamic>?> getProjectStatus(int routeId) async {
    final response = await get('/routes/$routeId/projects/me');

    if (response['success']) {
      return response['data'] as Map<String, dynamic>?;
    } else {
      throw Exception(response['error'] ?? 'Failed to get project status');
    }
  }

  /// Get user stats with caching
  Future<Map<String, dynamic>> getUserStats({bool forceRefresh = false}) async {
    final response = await get('/user/stats', forceRefresh: forceRefresh);

    if (response['success']) {
      return response['data'] as Map<String, dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Failed to load user stats');
    }
  }

  // Write operations that invalidate cache

  /// Like a route (invalidates user likes and route data)
  Future<void> likeRoute(int routeId) async {
    final response = await post('/routes/$routeId/like', {},
        invalidatePatterns: ['/user/likes', '/routes/$routeId', '/routes']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to like route');
    }
  }

  /// Unlike a route (invalidates user likes and route data)
  Future<void> unlikeRoute(int routeId) async {
    final response = await delete('/routes/$routeId/unlike',
        invalidatePatterns: ['/user/likes', '/routes/$routeId', '/routes']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to unlike route');
    }
  }

  /// Tick a route (invalidates user ticks, stats, and route data)
  Future<void> tickRoute(
    int routeId, {
    int attempts = 1,
    bool flash = false,
    String? notes,
  }) async {
    final body = {
      'attempts': attempts,
      'flash': flash,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await post('/routes/$routeId/ticks', body,
        invalidatePatterns: [
          '/user/ticks',
          '/user/stats',
          '/routes/$routeId',
          '/routes'
        ]);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to tick route');
    }
  }

  /// Untick a route (invalidates user ticks, stats, and route data)
  Future<void> untickRoute(int routeId) async {
    final response = await delete('/routes/$routeId/ticks',
        invalidatePatterns: [
          '/user/ticks',
          '/user/stats',
          '/routes/$routeId',
          '/routes'
        ]);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to untick route');
    }
  }

  /// Add project (invalidates user projects and route data)
  Future<void> addProject(int routeId, {String? notes}) async {
    final body = {
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await post('/routes/$routeId/projects', body,
        invalidatePatterns: ['/user/projects', '/routes/$routeId', '/routes']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to add project');
    }
  }

  /// Remove project (invalidates user projects and route data)
  Future<void> removeProject(int routeId) async {
    final response = await delete('/routes/$routeId/projects',
        invalidatePatterns: ['/user/projects', '/routes/$routeId', '/routes']);

    if (!response['success']) {
      throw Exception(response['error'] ?? 'Failed to remove project');
    }
  }

  /// Force refresh all data (clears entire cache)
  void clearAllCache() {
    _cacheService.clear();
  }

  /// Get user permissions with caching
  Future<Map<String, dynamic>> getUserPermissions(
      {bool forceRefresh = false}) async {
    final response = await get('/auth/permissions', forceRefresh: forceRefresh);

    if (response['success']) {
      return response['data'] as Map<String, dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Failed to load user permissions');
    }
  }

  /// Clear user-specific cache (useful for logout)
  void clearUserCache() {
    _cacheService.invalidateUserData();
  }

  /// Clear route-specific cache
  void clearRouteCache() {
    _cacheService.invalidateRouteData();
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getStats();
  }
}
