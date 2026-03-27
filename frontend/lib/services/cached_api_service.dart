import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_models.dart';
import '../models/lane_models.dart';
import '../providers/auth_provider.dart';
import '../config/api_config.dart';
import 'cache_service.dart';

/// Cached API service that wraps HTTP requests with intelligent caching
class CachedApiService {
  final AuthProvider authProvider;

  late final CacheService _cacheService = CacheService();

  CachedApiService({required this.authProvider});

  Map<String, dynamic> _successResponse(dynamic data, {bool? fromCache}) {
    final response = <String, dynamic>{
      'success': true,
      'data': data,
    };
    if (fromCache != null) {
      response['fromCache'] = fromCache;
    }
    return response;
  }

  Map<String, dynamic> _failureResponse(
    String error, {
    dynamic errorCode,
    bool? fromCache,
  }) {
    final response = <String, dynamic>{
      'success': false,
      'error': error,
    };
    if (errorCode != null) {
      response['errorCode'] = errorCode;
    }
    if (fromCache != null) {
      response['fromCache'] = fromCache;
    }
    return response;
  }

  Map<String, dynamic> _parseErrorResponse(
    http.Response response, {
    bool includeFromCache = false,
  }) {
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map &&
          errorData.containsKey('code') &&
          errorData.containsKey('message')) {
        return _failureResponse(
          errorData['message'] ?? 'Request failed',
          errorCode: errorData['code'],
          fromCache: includeFromCache ? false : null,
        );
      }
    } catch (_) {
      // Keep generic error message when response body is not a structured API error.
    }

    return _failureResponse(
      'Request failed with status ${response.statusCode}',
      fromCache: includeFromCache ? false : null,
    );
  }

  Map<String, dynamic> _networkErrorResponse(
    Object error, {
    bool includeFromCache = false,
  }) {
    return _failureResponse(
      'Network error: $error',
      fromCache: includeFromCache ? false : null,
    );
  }

  void _invalidateCachePatterns(List<String>? invalidatePatterns) {
    if (invalidatePatterns == null) {
      return;
    }
    for (final pattern in invalidatePatterns) {
      _cacheService.invalidatePattern(pattern);
    }
  }

  dynamic _requireSuccessData(
    Map<String, dynamic> response,
    String fallbackError,
  ) {
    if (response['success']) {
      return response['data'];
    }
    throw Exception(response['error'] ?? fallbackError);
  }

  void _ensureSuccess(
    Map<String, dynamic> response,
    String fallbackError,
  ) {
    if (!response['success']) {
      throw Exception(response['error'] ?? fallbackError);
    }
  }

  /// Generic cached GET request using JavaScript interop for web, HTTP for others
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Duration? cacheDuration,
    bool forceRefresh = false,
    bool isPermanentCache = false,
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
        return _successResponse(cachedData['data'], fromCache: true);
      }
    }

    // Use standard HTTP requests with JWT token
    // Build URL with query parameters
    String url = '${ApiConfig.baseUrl}$endpoint';
    var uri = Uri.parse(url);
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(
          queryParameters:
              params.map((key, value) => MapEntry(key, value.toString())));
    }

    try {
      // Get auth headers (includes JWT token if logged in)
      final headers = authProvider.getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData =
            _successResponse(json.decode(response.body), fromCache: false);

        // Cache the successful response
        if (isPermanentCache) {
          _cacheService.putPermanent(cacheKey, responseData);
        } else {
          _cacheService.put(cacheKey, responseData);
        }

        return responseData;
      } else {
        return _parseErrorResponse(response, includeFromCache: true);
      }
    } catch (e) {
      return _networkErrorResponse(e, includeFromCache: true);
    }
  }

  /// POST request (not cached, but invalidates related cache)
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    List<String>? invalidatePatterns,
  }) async {
    // Use standard HTTP requests with JWT token
    String url = '${ApiConfig.baseUrl}$endpoint';

    try {
      // Get auth headers (includes JWT token if logged in)
      final headers = authProvider.getAuthHeaders();

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Invalidate related cache entries after successful POST
        _invalidateCachePatterns(invalidatePatterns);

        return _successResponse(json.decode(response.body));
      } else {
        return _parseErrorResponse(response);
      }
    } catch (e) {
      return _networkErrorResponse(e);
    }
  }

  /// PUT request (not cached, but invalidates related cache)
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    List<String>? invalidatePatterns,
  }) async {
    // Use standard HTTP requests with JWT token
    String url = '${ApiConfig.baseUrl}$endpoint';

    try {
      // Get auth headers (includes JWT token if logged in)
      final headers = authProvider.getAuthHeaders();

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Invalidate related cache entries after successful PUT
        _invalidateCachePatterns(invalidatePatterns);

        return _successResponse(json.decode(response.body));
      } else {
        return _parseErrorResponse(response);
      }
    } catch (e) {
      return _networkErrorResponse(e);
    }
  }

  /// DELETE request (not cached, but invalidates related cache)
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    List<String>? invalidatePatterns,
  }) async {
    // Use standard HTTP requests with JWT token
    String url = '${ApiConfig.baseUrl}$endpoint';

    try {
      // Get auth headers (includes JWT token if logged in)
      final headers = authProvider.getAuthHeaders();

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Invalidate related cache entries after successful DELETE
        _invalidateCachePatterns(invalidatePatterns);

        return _successResponse(
          response.body.isNotEmpty ? json.decode(response.body) : {},
        );
      } else {
        return _parseErrorResponse(response);
      }
    } catch (e) {
      return _networkErrorResponse(e);
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
    print('🔧 CachedApiService.getRoutes() called');
    final params = <String, dynamic>{};
    if (wallSection != null) params['wall_section'] = wallSection;
    if (grade != null) params['grade'] = grade;
    if (lane != null) params['lane'] = lane;

    print('🔧 Calling get("/routes") with params: $params');
    final response =
        await get('/routes', params: params, forceRefresh: forceRefresh);
    print(
        '✅ get("/routes") returned: success=${response['success']}, data type=${response['data'].runtimeType}');

    if (response['success']) {
      print('🔧 Processing routes data...');
      final data = response['data'];
      print(
          '🔧 Data type: ${data.runtimeType}, length: ${data is List ? data.length : 'N/A'}');

      if (data is List) {
        print('🔧 Converting ${data.length} items to Route objects...');
        final routes = <Route>[];
        for (int i = 0; i < data.length; i++) {
          try {
            print('🔧 Converting route $i: ${data[i].runtimeType}');
            final route = Route.fromJson(data[i]);
            routes.add(route);
            print('✅ Route $i converted successfully: ${route.name}');
          } catch (e) {
            print('❌ Error converting route $i: $e');
            print('❌ Route data: ${data[i]}');
            rethrow;
          }
        }
        print('✅ All ${routes.length} routes converted successfully');
        return routes;
      } else {
        print('❌ Expected List but got ${data.runtimeType}');
        throw Exception('Expected List but got ${data.runtimeType}');
      }
    } else {
      print('❌ Request failed: ${response['error']}');
      throw Exception(response['error'] ?? 'Failed to load routes');
    }
  }

  /// Get single route with caching
  Future<Route> getRoute(int routeId, {bool forceRefresh = false}) async {
    final response = await get('/routes/$routeId', forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load route');
    return Route.fromJson(data);
  }

  /// Get wall sections with caching
  Future<List<String>> getWallSections({bool forceRefresh = false}) async {
    print('🔧 CachedApiService.getWallSections() called');
    final response = await get('/wall-sections', forceRefresh: forceRefresh);
    print(
        '✅ get("/wall-sections") returned: success=${response['success']}, data type=${response['data'].runtimeType}');

    if (response['success']) {
      final data = response['data'];
      print('🔧 Processing wall sections data: $data (${data.runtimeType})');
      if (data is List) {
        print('🔧 Converting to List<String>...');
        final result = data
            .where((item) => item != null)
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty && item != 'null')
            .toList();
        print('✅ Wall sections converted: $result');
        return result;
      } else {
        print('❌ Expected List but got ${data.runtimeType}');
        return <String>[];
      }
    } else {
      print('❌ Request failed: ${response['error']}');
      throw Exception(response['error'] ?? 'Failed to load wall sections');
    }
  }

  /// Get grades with permanent caching (never expires)
  Future<List<String>> getGrades({bool forceRefresh = false}) async {
    final response = await get(
      '/grades',
      forceRefresh: forceRefresh,
      isPermanentCache: true,
    );

    final data = _requireSuccessData(response, 'Failed to load grades');
    if (data is List) {
      return data
          .where((item) => item != null)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty && item != 'null')
          .toList();
    }
    return <String>[];
  }

  /// Get lanes with permanent caching (never expires)
  Future<List<Lane>> getLanes({bool forceRefresh = false}) async {
    print('🔧 CachedApiService.getLanes() called');
    final response = await get(
      '/lanes',
      forceRefresh: forceRefresh,
      isPermanentCache: true,
    );
    print(
        '✅ get("/lanes") returned: success=${response['success']}, data type=${response['data'].runtimeType}');

    if (response['success']) {
      final data = response['data'];
      print('🔧 Processing lanes data: $data (${data.runtimeType})');

      if (data is List) {
        print('🔧 Converting ${data.length} items to Lane objects...');
        final lanes = <Lane>[];
        for (int i = 0; i < data.length; i++) {
          try {
            print('🔧 Converting lane $i: ${data[i].runtimeType}');
            final lane = Lane.fromJson(data[i]);
            lanes.add(lane);
            print(
                '✅ Lane $i converted successfully: ${lane.id} - ${lane.name}');
          } catch (e) {
            print('❌ Error converting lane $i: $e');
            print('❌ Lane data: ${data[i]}');
            rethrow;
          }
        }
        print('✅ All ${lanes.length} lanes converted successfully');
        return lanes;
      } else {
        print('❌ Expected List but got ${data.runtimeType}');
        return <Lane>[];
      }
    } else {
      print('❌ Request failed: ${response['error']}');
      throw Exception(response['error'] ?? 'Failed to load lanes');
    }
  }

  /// Get grade definitions with permanent caching (never expires)
  Future<List<Map<String, dynamic>>> getGradeDefinitions(
      {bool forceRefresh = false}) async {
    final response = await get(
      '/grade-definitions',
      forceRefresh: forceRefresh,
      isPermanentCache: true,
    );

    final data =
        _requireSuccessData(response, 'Failed to load grade definitions');
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  /// Get hold colors with permanent caching (never expires)
  Future<List<Map<String, dynamic>>> getHoldColors(
      {bool forceRefresh = false}) async {
    final response = await get(
      '/hold-colors',
      forceRefresh: forceRefresh,
      isPermanentCache: true,
    );

    final data = _requireSuccessData(response, 'Failed to load hold colors');
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  /// Get grade colors with permanent caching (never expires)
  Future<Map<String, String>> getGradeColors(
      {bool forceRefresh = false}) async {
    final response = await get(
      '/grade-colors',
      forceRefresh: forceRefresh,
      isPermanentCache: true,
    );

    final data = _requireSuccessData(response, 'Failed to load grade colors');
    if (data is Map) {
      final result = <String, String>{};
      for (final entry in data.entries) {
        final key = entry.key?.toString();
        final value = entry.value?.toString();
        if (key == null || key.isEmpty || key == 'null') {
          continue;
        }
        if (value == null || value.isEmpty || value == 'null') {
          continue;
        }
        result[key] = value;
      }
      return result;
    }
    return <String, String>{};
  }

  /// Get user ticks with caching
  Future<List<dynamic>> getUserTicks({bool forceRefresh = false}) async {
    final response = await get('/user/ticks', forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load user ticks');
    return data as List<dynamic>;
  }

  /// Get user likes with caching
  Future<List<dynamic>> getUserLikes({bool forceRefresh = false}) async {
    final response = await get('/user/likes', forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load user likes');
    return data as List<dynamic>;
  }

  /// Get user projects with caching - returns List<Project>
  Future<List<Project>> getUserProjectsTyped(
      {bool forceRefresh = false}) async {
    final response = await get('/user/projects', forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load user projects');
    final projects = data as List<dynamic>;
    return projects.map((json) => Project.fromJson(json)).toList();
  }

  /// Get user projects with caching
  Future<List<dynamic>> getUserProjects({bool forceRefresh = false}) async {
    final response = await get('/user/projects', forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load user projects');
    return data as List<dynamic>;
  }

  /// Create a new route
  Future<Route> createRoute(Route route) async {
    final response =
        await post('/routes', route.toJson(), invalidatePatterns: ['/routes']);
    final data = _requireSuccessData(response, 'Failed to create route');
    return Route.fromJson(data);
  }

  /// Get user's tick status for a route
  Future<Map<String, dynamic>> getUserTick(int routeId) async {
    final response = await get('/routes/$routeId/ticks/me');
    final data = _requireSuccessData(response, 'Failed to get tick status');
    return data as Map<String, dynamic>;
  }

  /// Add attempts to a route (without marking as sent)
  Future<void> addAttempts(int routeId, int attempts,
      {String? notes, String? attemptType}) async {
    final body = {
      'attempts': attempts,
      if (attemptType != null) 'attempt_type': attemptType,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await post('/routes/$routeId/attempts', body,
        invalidatePatterns: ['/user/ticks', '/user/stats', '/routes/$routeId']);
    _ensureSuccess(response, 'Failed to add attempts');
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
    _ensureSuccess(response, 'Failed to mark send');
  }

  /// Remove a specific send type from a route
  Future<void> unmarkSend(int routeId, String sendType) async {
    final body = {
      'send_type': sendType,
    };

    final response = await post('/routes/$routeId/unsend', body,
        invalidatePatterns: [
          '/user/ticks',
          '/user/stats',
          '/routes/$routeId',
          '/routes'
        ]);
    _ensureSuccess(response, 'Failed to unmark send');
  }

  /// Update notes for a route without affecting attempts or sends
  Future<void> updateRouteNotes(int routeId, String notes) async {
    final body = {
      'route_id': routeId,
      'notes': notes,
    };

    final response = await put('/route/notes', body, invalidatePatterns: [
      '/user/ticks',
      '/routes/$routeId',
    ]);
    _ensureSuccess(response, 'Failed to update notes');
  }

  /// Add a comment to a route
  Future<void> addComment(int routeId, String content) async {
    final body = {'content': content};

    final response = await post('/routes/$routeId/comments', body,
        invalidatePatterns: ['/routes/$routeId']);
    _ensureSuccess(response, 'Failed to add comment');
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
    _ensureSuccess(response, 'Failed to propose grade');
  }

  /// Get user's grade proposal for a route
  Future<GradeProposal?> getUserGradeProposal(int routeId) async {
    final response = await get('/routes/$routeId/grade-proposals/me');

    final data = _requireSuccessData(response, 'Failed to get grade proposal');
    // Check if data is null, empty object, or doesn't have required fields
    if (data == null ||
        data is Map<String, dynamic> && (data.isEmpty || data['id'] == null)) {
      return null;
    }
    return GradeProposal.fromJson(data);
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
    _ensureSuccess(response, 'Failed to add warning');
  }

  /// Get user stats with caching
  Future<Map<String, dynamic>> getUserStats({bool forceRefresh = false}) async {
    final response = await get('/user/stats', forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load user stats');
    return data as Map<String, dynamic>;
  }

  /// Like a route (invalidates user likes and route data)
  Future<void> likeRoute(int routeId) async {
    final response = await post('/routes/$routeId/like', {},
        invalidatePatterns: ['/user/likes', '/routes/$routeId', '/routes']);
    _ensureSuccess(response, 'Failed to like route');
  }

  /// Unlike a route (invalidates user likes and route data)
  Future<void> unlikeRoute(int routeId) async {
    final response = await delete('/routes/$routeId/unlike',
        invalidatePatterns: ['/user/likes', '/routes/$routeId', '/routes']);
    _ensureSuccess(response, 'Failed to unlike route');
  }

  Future<bool> getUserLikeStatus(int routeId) async {
    final response = await get('/routes/$routeId/like-status');
    final data = _requireSuccessData(response, 'Failed to get like status');
    return data['liked'] as bool;
  }

  /// Add project (invalidates user projects and route data)
  Future<void> addProject(int routeId, {String? notes}) async {
    final body = {
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await post('/routes/$routeId/projects', body,
        invalidatePatterns: ['/user/projects', '/routes/$routeId', '/routes']);
    _ensureSuccess(response, 'Failed to add project');
  }

  /// Remove project (invalidates user projects and route data)
  Future<void> removeProject(int routeId) async {
    final response = await delete('/routes/$routeId/projects',
        invalidatePatterns: ['/user/projects', '/routes/$routeId', '/routes']);
    _ensureSuccess(response, 'Failed to remove project');
  }

  /// Force refresh all data (clears entire cache)
  void clearAllCache() {
    _cacheService.clear();
  }

  /// Get user permissions with caching
  Future<Map<String, dynamic>> getUserPermissions(
      {bool forceRefresh = false}) async {
    final response = await get('/auth/permissions', forceRefresh: forceRefresh);
    final data =
        _requireSuccessData(response, 'Failed to load user permissions');
    return data as Map<String, dynamic>;
  }

  /// Clear user-specific cache (useful for logout)
  void clearUserCache() {
    _cacheService.invalidateUserData();
  }

  /// Clear route-specific cache
  void clearRouteCache() {
    _cacheService.invalidateRouteData();
  }

  /// Clear permanent cache for all static data
  void clearPermanentCache() {
    _cacheService.clearPermanentCache();
  }

  /// Remove specific cache entry
  void removeCacheEntry(String key) {
    _cacheService.remove(key);
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getStats();
  }

  /// Get name proposals for a route
  Future<List<NameProposal>> getRouteNameProposals(int routeId,
      {bool forceRefresh = false}) async {
    final response = await get('/routes/$routeId/name-proposals',
        forceRefresh: forceRefresh);
    final data = _requireSuccessData(response, 'Failed to load name proposals')
        as List<dynamic>;
    return data
        .map((json) => NameProposal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Propose a name for a route
  Future<void> proposeRouteName(int routeId, String proposedName) async {
    final body = {'proposed_name': proposedName};

    final response = await post('/routes/$routeId/name-proposals', body,
        invalidatePatterns: [
          '/routes/$routeId/name-proposals',
          '/routes/$routeId'
        ]);
    _ensureSuccess(response, 'Failed to propose name');
  }

  /// Vote for a name proposal
  Future<void> voteForNameProposal(int routeId, int proposalId) async {
    final response = await post('/name-proposals/$proposalId/vote', {},
        invalidatePatterns: [
          '/routes/$routeId/name-proposals',
          '/routes/$routeId'
        ]);
    _ensureSuccess(response, 'Failed to vote for proposal');
  }

  /// Get user's action status for a route's name proposals
  Future<Map<String, dynamic>> getUserNameProposalAction(int routeId) async {
    final response = await get('/routes/$routeId/name-proposals/user-action');
    final data =
        _requireSuccessData(response, 'Failed to get user action status');
    return data as Map<String, dynamic>;
  }
}
