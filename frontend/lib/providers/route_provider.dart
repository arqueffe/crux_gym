import 'package:flutter/foundation.dart';
import '../models/route_models.dart';
import '../models/lane_models.dart';
import '../models/route_filter_models.dart';
import '../services/cached_api_service.dart';
import '../providers/auth_provider.dart';
import '../utils/route_filtering.dart';
import '../utils/route_response_parsing.dart';
import '../utils/route_sorting.dart';

enum _ActionRefreshStrategy {
  none,
  selectedIfOpen,
  selectedAlways,
  routesOnly,
  selectedIfOpenAndRoutes,
  selectedAlwaysAndRoutes,
}

class RouteProvider extends ChangeNotifier {
  late final CachedApiService _apiService;
  final AuthProvider _authProvider;

  RouteProvider({required AuthProvider authProvider})
      : _authProvider = authProvider {
    _apiService = CachedApiService(authProvider: authProvider);
  }

  List<Route> _routes = [];
  List<Route> _currentRoutes = [];
  Route? _selectedRoute;
  bool _isLoading = false;
  String? _error;
  final Set<String> _selectedWallSections = {};
  final Set<int> _selectedLaneIds = {};
  int? _selectedMinGradeIndex;
  int? _selectedMaxGradeIndex;
  String? _selectedRouteSetter;
  List<String> _wallSections = [];
  List<String> _grades = [];
  List<Lane> _lanes = [];
  List<String> _routeSetters = [];
  List<Map<String, dynamic>> _gradeDefinitions = [];
  List<Map<String, dynamic>> _holdColors = [];
  Map<String, String> _gradeColors = {};
  SortOption _selectedSort = SortOption.newest;
  FilterState _tickedFilter = FilterState.all;
  FilterState _likedFilter = FilterState.all;
  FilterState _warnedFilter = FilterState.all;
  FilterState _projectFilter = FilterState.all;
  final Set<int> _userTickedRouteIds = <int>{};
  final Set<int> _userLikedRouteIds = <int>{};
  final Set<int> _userProjectRouteIds = <int>{};
  bool _nameProposalsEndpointAvailable = true;

  // Getters
  List<Route> get routes => _currentRoutes;
  Route? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get selectedWallSections =>
      Set.unmodifiable(_selectedWallSections);
  Set<int> get selectedLaneIds => Set.unmodifiable(_selectedLaneIds);
  int? get selectedMinGradeIndex => _selectedMinGradeIndex;
  int? get selectedMaxGradeIndex => _selectedMaxGradeIndex;

  // Backward-compatible getters used by older UI widgets.
  String? get selectedWallSection =>
      _selectedWallSections.isEmpty ? null : _selectedWallSections.first;
  String? get selectedGrade {
    if (_selectedMinGradeIndex == null || _selectedMaxGradeIndex == null) {
      return null;
    }
    if (_selectedMinGradeIndex == _selectedMaxGradeIndex &&
        _selectedMinGradeIndex! >= 0 &&
        _selectedMinGradeIndex! < availableGrades.length) {
      return availableGrades[_selectedMinGradeIndex!];
    }
    return null;
  }

  int? get selectedLane =>
      _selectedLaneIds.isEmpty ? null : _selectedLaneIds.first;

  bool get hasGradeRangeFilter {
    final gradeScale = availableGrades;
    if (gradeScale.isEmpty ||
        _selectedMinGradeIndex == null ||
        _selectedMaxGradeIndex == null) {
      return false;
    }
    return !(_selectedMinGradeIndex == 0 &&
        _selectedMaxGradeIndex == gradeScale.length - 1);
  }

  String? get selectedMinGrade => _selectedMinGradeIndex != null &&
          _selectedMinGradeIndex! < availableGrades.length
      ? availableGrades[_selectedMinGradeIndex!]
      : null;
  String? get selectedMaxGrade => _selectedMaxGradeIndex != null &&
          _selectedMaxGradeIndex! < availableGrades.length
      ? availableGrades[_selectedMaxGradeIndex!]
      : null;
  String? get selectedRouteSetter => _selectedRouteSetter;
  List<String> get wallSections => _wallSections;
  List<String> get grades => _grades;
  List<String> get availableGrades {
    final routeGradeNames =
        _routes.map((route) => route.gradeName).whereType<String>().toSet();

    if (routeGradeNames.isEmpty) {
      return _grades;
    }

    return _grades.where((grade) => routeGradeNames.contains(grade)).toList();
  }

  List<Lane> get lanes => _lanes;
  List<Lane> get lanesWithRoutes {
    final laneIdsInRoutes = _routes.map((route) => route.lane).toSet();
    return _lanes.where((lane) => laneIdsInRoutes.contains(lane.id)).toList();
  }

  List<int> get laneIds => _lanes.map((lane) => lane.id).toList();
  List<String> get routeSetters => _routeSetters;
  List<Map<String, dynamic>> get gradeDefinitions => _gradeDefinitions;
  List<Map<String, dynamic>> get holdColors => _holdColors;
  Map<String, String> get gradeColors => _gradeColors;
  SortOption get selectedSort => _selectedSort;
  FilterState get tickedFilter => _tickedFilter;
  FilterState get likedFilter => _likedFilter;
  FilterState get warnedFilter => _warnedFilter;
  FilterState get projectFilter => _projectFilter;
  CachedApiService get apiService => _apiService;

  bool get hasActiveFilters =>
      _selectedWallSections.isNotEmpty ||
      hasGradeRangeFilter ||
      _selectedLaneIds.isNotEmpty ||
      _selectedRouteSetter != null ||
      _tickedFilter != FilterState.all ||
      _likedFilter != FilterState.all ||
      _warnedFilter != FilterState.all ||
      _projectFilter != FilterState.all;

  // Load initial data
  Future<void> loadInitialData({bool forceRefresh = false}) async {
    print('🔧 RouteProvider.loadInitialData() called');
    try {
      await Future.wait([
        loadRoutes(forceRefresh: forceRefresh),
        loadWallSections(),
        loadGrades(),
        loadLanes(),
        loadRouteSetters(),
        loadGradeColors(),
      ]);
      print('✅ RouteProvider.loadInitialData() completed successfully');
    } catch (e) {
      print('❌ RouteProvider.loadInitialData() error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Load routes with optional filtering
  Future<void> loadRoutes({bool forceRefresh = false}) async {
    print('🔧 RouteProvider.loadRoutes() called');
    _setLoading(true);
    try {
      // Always fetch all routes first to ensure we have the complete dataset
      print('🔧 Calling _apiService.getRoutes()...');
      _routes = await _apiService.getRoutes(forceRefresh: forceRefresh);
      print('✅ _apiService.getRoutes() returned ${_routes.length} routes');

      // Enrich unnamed routes with name proposals because /routes payload does
      // not include proposal details needed for display fallback.
      await _hydrateUnnamedRoutesWithNameProposals(
        forceRefresh: forceRefresh,
      );

      // Ensure grade definitions and hold colors are loaded before populating route data
      print('🔧 Ensuring grade definitions and hold colors are loaded...');
      await Future.wait([
        loadGradeDefinitions(), // Permanently cached - no forceRefresh needed
        loadHoldColors(), // Permanently cached - no forceRefresh needed
      ]);
      print('✅ Grade definitions and hold colors loaded');

      // Populate route information (colors and grades) for routes
      print('🔧 Populating route data (colors and grades)...');
      _populateRouteData();
      print('✅ Route data populated');

      // Refresh per-user interaction route IDs used by user-scoped filters.
      await _refreshUserInteractionRouteIds(forceRefresh: forceRefresh);

      // Apply client-side filters
      print('🔧 Applying client-side filters...');
      _applyClientSideFilters();
      print(
          '✅ Client-side filters applied, ${_currentRoutes.length} routes after filtering');

      // Apply sorting
      print('🔧 Applying sorting...');
      _sortRoutes();
      print('✅ Sorting applied');

      // Update route setters list after loading routes
      print('🔧 Loading route setters...');
      await loadRouteSetters();
      print('✅ Route setters loaded');

      _error = null;
      print('✅ RouteProvider.loadRoutes() completed successfully');
    } catch (e) {
      print('❌ RouteProvider.loadRoutes() error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Refresh routes while preserving current filters
  Future<void> refreshRoutes({bool forceRefresh = false}) async {
    await loadRoutes(forceRefresh: forceRefresh);
  }

  Future<void> _refreshUserInteractionRouteIds(
      {bool forceRefresh = false}) async {
    _userTickedRouteIds.clear();
    _userLikedRouteIds.clear();
    _userProjectRouteIds.clear();

    final currentUser = _authProvider.currentUser;
    if (currentUser == null) {
      return;
    }

    try {
      final results = await Future.wait<List<dynamic>>([
        _apiService.getUserTicks(forceRefresh: forceRefresh),
        _apiService.getUserLikes(forceRefresh: forceRefresh),
        _apiService.getUserProjects(forceRefresh: forceRefresh),
      ]);

      _userTickedRouteIds.addAll(extractLeadSentTickRouteIds(results[0]));
      _userLikedRouteIds.addAll(extractRouteIds(results[1]));
      _userProjectRouteIds.addAll(extractRouteIds(results[2]));
    } catch (e) {
      // Do not fail route loading if user interaction endpoints fail.
    }
  }

  // Apply client-side filters (for features not supported by API)
  void _applyClientSideFilters() {
    _currentRoutes = applyRouteFilters(
      routes: _routes,
      selectedWallSections: _selectedWallSections,
      selectedLaneIds: _selectedLaneIds,
      hasGradeRangeFilter: hasGradeRangeFilter,
      selectedMinGradeIndex: _selectedMinGradeIndex,
      selectedMaxGradeIndex: _selectedMaxGradeIndex,
      availableGrades: availableGrades,
      selectedRouteSetter: _selectedRouteSetter,
      tickedFilter: _tickedFilter,
      likedFilter: _likedFilter,
      warnedFilter: _warnedFilter,
      projectFilter: _projectFilter,
      userTickedRouteIds: _userTickedRouteIds,
      userLikedRouteIds: _userLikedRouteIds,
      userProjectRouteIds: _userProjectRouteIds,
    );
  }

  // Load specific route with details
  Future<void> loadRoute(int routeId, {bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      _selectedRoute =
          await _apiService.getRoute(routeId, forceRefresh: forceRefresh);

      if (_selectedRoute != null) {
        _selectedRoute = await _hydrateRouteNameProposals(
          _selectedRoute!,
          forceRefresh: forceRefresh,
        );
      }

      // Ensure grade definitions and hold colors are loaded before populating route data
      await Future.wait([
        loadGradeDefinitions(), // Permanently cached - no forceRefresh needed
        loadHoldColors(), // Permanently cached - no forceRefresh needed
      ]);

      // Populate route information (colors and grades) for the selected route
      if (_selectedRoute != null) {
        _selectedRoute = _populateRouteDataForSingleRoute(_selectedRoute!);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Create new route
  Future<bool> createRoute(Route route) async {
    _setLoading(true);
    try {
      final newRoute = await _apiService.createRoute(route);
      _routes.add(newRoute);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> _refreshAfterAction({
    required _ActionRefreshStrategy strategy,
    int? routeId,
  }) async {
    switch (strategy) {
      case _ActionRefreshStrategy.none:
        return;
      case _ActionRefreshStrategy.selectedIfOpen:
        if (routeId != null && _selectedRoute?.id == routeId) {
          await loadRoute(routeId);
        }
        return;
      case _ActionRefreshStrategy.selectedAlways:
        if (routeId != null) {
          await loadRoute(routeId);
        }
        return;
      case _ActionRefreshStrategy.routesOnly:
        await loadRoutes();
        return;
      case _ActionRefreshStrategy.selectedIfOpenAndRoutes:
        if (routeId != null && _selectedRoute?.id == routeId) {
          await loadRoute(routeId);
        }
        await loadRoutes();
        return;
      case _ActionRefreshStrategy.selectedAlwaysAndRoutes:
        if (routeId != null) {
          await loadRoute(routeId);
        }
        await loadRoutes();
        return;
    }
  }

  Future<bool> _executeRouteAction({
    required Future<void> Function() action,
    _ActionRefreshStrategy refreshStrategy = _ActionRefreshStrategy.none,
    int? routeId,
  }) async {
    try {
      await action();
      await _refreshAfterAction(strategy: refreshStrategy, routeId: routeId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _toggleLikeRequest(int routeId) async {
    final isLiked = await getUserLikeStatus(routeId);
    if (isLiked) {
      await _apiService.unlikeRoute(routeId);
    } else {
      await _apiService.likeRoute(routeId);
    }
  }

  // Like/Unlike route
  Future<bool> toggleLike(int routeId) async {
    final currentUser = _authProvider.currentUser;
    if (currentUser == null) return false;

    return _executeRouteAction(
      action: () => _toggleLikeRequest(routeId),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedAlwaysAndRoutes,
    );
  }

  // Like/Unlike route (optimized for UI interactions)
  Future<bool> toggleLikeOptimized(int routeId) async {
    final currentUser = _authProvider.currentUser;
    if (currentUser == null) return false;

    return _executeRouteAction(
      action: () => _toggleLikeRequest(routeId),
      routeId: routeId,
    );
  }

  // Check if user has liked a route
  Future<bool> getUserLikeStatus(int routeId) async {
    try {
      final currentUser = _authProvider.currentUser;
      if (currentUser == null) return false;

      final isLiked = await _apiService.getUserLikeStatus(routeId);
      return isLiked;
    } catch (e) {
      return false;
    }
  }

  // Add attempts to a route
  Future<bool> addAttempts(int routeId, int attempts, {String? notes}) async {
    return _executeRouteAction(
      action: () => _apiService.addAttempts(routeId, attempts, notes: notes),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedIfOpenAndRoutes,
    );
  }

  // Add attempts to a route (optimized for UI interactions)
  Future<bool> addAttemptsOptimized(int routeId, int attempts,
      {String? notes, String? attemptType}) async {
    return _executeRouteAction(
      action: () => _apiService.addAttempts(
        routeId,
        attempts,
        notes: notes,
        attemptType: attemptType,
      ),
      routeId: routeId,
    );
  }

  // Mark a route as sent in a specific style
  Future<bool> markSend(int routeId, String sendType, {String? notes}) async {
    return _executeRouteAction(
      action: () => _apiService.markSend(routeId, sendType, notes: notes),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedIfOpenAndRoutes,
    );
  }

  // Mark a route as sent in a specific style (optimized for UI interactions)
  Future<bool> markSendOptimized(int routeId, String sendType,
      {String? notes}) async {
    return _executeRouteAction(
      action: () => _apiService.markSend(routeId, sendType, notes: notes),
      routeId: routeId,
    );
  }

  // Remove a specific send type from a route
  Future<bool> unmarkSend(int routeId, String sendType) async {
    return _executeRouteAction(
      action: () => _apiService.unmarkSend(routeId, sendType),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedIfOpenAndRoutes,
    );
  }

  // Remove a specific send type from a route (optimized for UI interactions)
  Future<bool> unmarkSendOptimized(int routeId, String sendType) async {
    return _executeRouteAction(
      action: () => _apiService.unmarkSend(routeId, sendType),
      routeId: routeId,
    );
  }

  // Update route notes without affecting attempts or sends
  Future<bool> updateRouteNotes(int routeId, String notes) async {
    return _executeRouteAction(
      action: () => _apiService.updateRouteNotes(routeId, notes),
      routeId: routeId,
    );
  }

  // Check if user has ticked a route
  Future<Map<String, dynamic>?> getUserTickStatus(int routeId) async {
    try {
      return await _apiService.getUserTick(routeId);
    } catch (e) {
      return null;
    }
  }

  // Add comment
  Future<bool> addComment(int routeId, String content) async {
    return _executeRouteAction(
      action: () => _apiService.addComment(routeId, content),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedAlways,
    );
  }

  // Add comment (optimized for UI interactions)
  Future<bool> addCommentOptimized(int routeId, String content) async {
    return _executeRouteAction(
      action: () => _apiService.addComment(routeId, content),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedIfOpen,
    );
  }

  // Propose grade
  Future<bool> proposeGrade(
    int routeId,
    String proposedGrade,
    String? reasoning,
  ) async {
    return _executeRouteAction(
      action: () =>
          _apiService.proposeGrade(routeId, proposedGrade, reasoning ?? ''),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedAlways,
    );
  }

  // Propose grade (optimized for UI interactions)
  Future<bool> proposeGradeOptimized(
    int routeId,
    String proposedGrade,
    String? reasoning,
  ) async {
    return _executeRouteAction(
      action: () =>
          _apiService.proposeGrade(routeId, proposedGrade, reasoning ?? ''),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedIfOpen,
    );
  }

  // Get current user's grade proposal for a route
  Future<GradeProposal?> getUserGradeProposal(int routeId) async {
    try {
      return await _apiService.getUserGradeProposal(routeId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Add warning
  Future<bool> addWarning(
    int routeId,
    String warningType,
    String description,
  ) async {
    return _executeRouteAction(
      action: () => _apiService.addWarning(routeId, warningType, description),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedAlways,
    );
  }

  // Add warning (optimized for UI interactions)
  Future<bool> addWarningOptimized(
    int routeId,
    String warningType,
    String description,
  ) async {
    return _executeRouteAction(
      action: () => _apiService.addWarning(routeId, warningType, description),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.selectedIfOpen,
    );
  }

  // Load wall sections
  Future<void> loadWallSections({bool forceRefresh = false}) async {
    print('🔧 RouteProvider.loadWallSections() called');
    try {
      print('🔧 Calling _apiService.getWallSections()...');
      _wallSections =
          await _apiService.getWallSections(forceRefresh: forceRefresh);
      print(
          '✅ _apiService.getWallSections() returned ${_wallSections.length} sections: $_wallSections');
    } catch (e) {
      print('❌ RouteProvider.loadWallSections() error: $e');
      print('❌ Error type: ${e.runtimeType}');
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load grades (permanently cached)
  Future<void> loadGrades() async {
    print('🔧 RouteProvider.loadGrades() called');
    try {
      print('🔧 Calling _apiService.getGrades()...');
      _grades = await _apiService.getGrades();
      _sanitizeGradeRangeFilter();
      print(
          '✅ _apiService.getGrades() returned ${_grades.length} grades: $_grades');
    } catch (e) {
      print('❌ RouteProvider.loadGrades() error: $e');
      print('❌ Error type: ${e.runtimeType}');
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load lanes (permanently cached)
  Future<void> loadLanes() async {
    print('🔧 RouteProvider.loadLanes() called');
    try {
      print('🔧 Calling _apiService.getLanes()...');
      _lanes = await _apiService.getLanes();
      print(
          '✅ _apiService.getLanes() returned ${_lanes.length} lanes: ${_lanes.map((l) => 'ID:${l.id} Name:${l.name}').toList()}');
    } catch (e) {
      print('❌ RouteProvider.loadLanes() error: $e');
      print('❌ Error type: ${e.runtimeType}');
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load route setters
  Future<void> loadRouteSetters() async {
    try {
      // Extract route setters from existing routes
      final setters =
          _routes.map((route) => route.routeSetter).toSet().toList();
      setters.sort();
      _routeSetters = setters;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load grade definitions with colors (permanently cached)
  Future<void> loadGradeDefinitions() async {
    try {
      _gradeDefinitions = await _apiService.getGradeDefinitions();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load hold colors (permanently cached)
  Future<void> loadHoldColors() async {
    try {
      _holdColors = await _apiService.getHoldColors();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load grade colors mapping (permanently cached)
  Future<void> loadGradeColors() async {
    print('🔧 RouteProvider.loadGradeColors() called');
    try {
      print('🔧 Calling _apiService.getGradeColors()...');
      _gradeColors = await _apiService.getGradeColors();
      print(
          '✅ _apiService.getGradeColors() returned ${_gradeColors.length} grade colors');
    } catch (e) {
      print('❌ RouteProvider.loadGradeColors() error: $e');
      print('❌ Error type: ${e.runtimeType}');
      _error = e.toString();
    }
    notifyListeners();
  }

  // Administrative methods for refreshing permanent cache

  /// Clear all permanently cached static data and reload from server
  /// Use this when static data has been updated on the backend
  Future<void> refreshStaticData() async {
    print('🔄 Refreshing all static data (clearing permanent cache)...');

    // Clear permanent cache for all static data
    _apiService.clearPermanentCache();

    // Reload all static data
    await Future.wait([
      loadGrades(),
      loadLanes(),
      loadGradeDefinitions(),
      loadHoldColors(),
      loadGradeColors(),
    ]);

    print('✅ All static data refreshed');
  }

  /// Clear permanently cached grades and reload
  Future<void> refreshGrades() async {
    _apiService.removeCacheEntry('grades');
    await loadGrades();
  }

  /// Clear permanently cached lanes and reload
  Future<void> refreshLanes() async {
    _apiService.removeCacheEntry('lanes');
    await loadLanes();
  }

  /// Clear permanently cached grade definitions and reload
  Future<void> refreshGradeDefinitions() async {
    _apiService.removeCacheEntry('grade_definitions');
    await loadGradeDefinitions();
  }

  /// Clear permanently cached hold colors and reload
  Future<void> refreshHoldColors() async {
    _apiService.removeCacheEntry('hold_colors');
    await loadHoldColors();
  }

  /// Clear permanently cached grade colors and reload
  Future<void> refreshGradeColors() async {
    _apiService.removeCacheEntry('grade_colors');
    await loadGradeColors();
  }

  void _mutateFilters(void Function() mutation) {
    mutation();
    _applyFiltersAndSort();
  }

  void _setSingleSelection<T>(Set<T> target, T? value) {
    target
      ..clear()
      ..addAll(value == null ? <T>[] : <T>[value]);
  }

  void _setMultiSelection<T>(Set<T> target, Set<T> values) {
    target
      ..clear()
      ..addAll(values);
  }

  void _toggleSelection<T>(Set<T> target, T value) {
    if (target.contains(value)) {
      target.remove(value);
    } else {
      target.add(value);
    }
  }

  void _setInteractionFilter(
    FilterState state,
    void Function(FilterState) assign,
  ) {
    _mutateFilters(() {
      assign(state);
    });
  }

  void _resetBaseFilters() {
    _selectedWallSections.clear();
    _selectedLaneIds.clear();
    _selectedMinGradeIndex = null;
    _selectedMaxGradeIndex = null;
  }

  // Filter methods
  void setWallSectionFilter(String? wallSection) {
    _mutateFilters(() {
      _setSingleSelection<String>(_selectedWallSections, wallSection);
    });
  }

  void setWallSectionsFilter(Set<String> wallSections) {
    _mutateFilters(() {
      _setMultiSelection<String>(_selectedWallSections, wallSections);
    });
  }

  void toggleWallSectionFilter(String wallSection) {
    _mutateFilters(() {
      _toggleSelection<String>(_selectedWallSections, wallSection);
    });
  }

  void setGradeFilter(String? grade) {
    if (grade == null) {
      _selectedMinGradeIndex = null;
      _selectedMaxGradeIndex = null;
      _applyFiltersAndSort();
      return;
    }

    final gradeIndex = availableGrades.indexOf(grade);
    if (gradeIndex == -1) {
      return;
    }

    _selectedMinGradeIndex = gradeIndex;
    _selectedMaxGradeIndex = gradeIndex;
    _applyFiltersAndSort();
  }

  void setGradeRangeFilter(int? minIndex, int? maxIndex) {
    final gradeScale = availableGrades;
    if (minIndex == null || maxIndex == null || gradeScale.isEmpty) {
      _selectedMinGradeIndex = null;
      _selectedMaxGradeIndex = null;
      _applyFiltersAndSort();
      return;
    }

    int normalizedMin = minIndex;
    int normalizedMax = maxIndex;

    if (normalizedMin > normalizedMax) {
      final temp = normalizedMin;
      normalizedMin = normalizedMax;
      normalizedMax = temp;
    }

    normalizedMin = normalizedMin.clamp(0, gradeScale.length - 1);
    normalizedMax = normalizedMax.clamp(0, gradeScale.length - 1);

    _selectedMinGradeIndex = normalizedMin;
    _selectedMaxGradeIndex = normalizedMax;

    // Treat full-range selection as "no grade filter".
    if (_selectedMinGradeIndex == 0 &&
        _selectedMaxGradeIndex == gradeScale.length - 1) {
      _selectedMinGradeIndex = null;
      _selectedMaxGradeIndex = null;
    }

    _applyFiltersAndSort();
  }

  void setLaneFilter(int? lane) {
    _mutateFilters(() {
      _setSingleSelection<int>(_selectedLaneIds, lane);
    });
  }

  void setLaneIdsFilter(Set<int> laneIds) {
    _mutateFilters(() {
      _setMultiSelection<int>(_selectedLaneIds, laneIds);
    });
  }

  void toggleLaneFilter(int laneId) {
    _mutateFilters(() {
      _toggleSelection<int>(_selectedLaneIds, laneId);
    });
  }

  void setRouteSetterFilter(String? routeSetter) {
    _mutateFilters(() {
      _selectedRouteSetter = routeSetter;
    });
  }

  void setSortOption(SortOption sortOption) {
    _mutateFilters(() {
      _selectedSort = sortOption;
    });
  }

  void setTickedFilter(FilterState state) {
    _setInteractionFilter(state, (value) => _tickedFilter = value);
  }

  void setLikedFilter(FilterState state) {
    _setInteractionFilter(state, (value) => _likedFilter = value);
  }

  void setWarnedFilter(FilterState state) {
    _setInteractionFilter(state, (value) => _warnedFilter = value);
  }

  void setProjectFilter(FilterState state) {
    _setInteractionFilter(state, (value) => _projectFilter = value);
  }

  void clearFilters() {
    _resetBaseFilters();
    loadRoutes();
  }

  void clearAllFilters() {
    _resetBaseFilters();
    _selectedRouteSetter = null;
    _tickedFilter = FilterState.all;
    _likedFilter = FilterState.all;
    _warnedFilter = FilterState.all;
    _projectFilter = FilterState.all;
    _selectedSort = SortOption.newest;
    loadRoutes();
  }

  void _sanitizeGradeRangeFilter() {
    final gradeScale = availableGrades;
    if (gradeScale.isEmpty) {
      _selectedMinGradeIndex = null;
      _selectedMaxGradeIndex = null;
      return;
    }

    if (_selectedMinGradeIndex == null || _selectedMaxGradeIndex == null) {
      return;
    }

    _selectedMinGradeIndex =
        _selectedMinGradeIndex!.clamp(0, gradeScale.length - 1);
    _selectedMaxGradeIndex =
        _selectedMaxGradeIndex!.clamp(0, gradeScale.length - 1);

    if (_selectedMinGradeIndex! > _selectedMaxGradeIndex!) {
      final temp = _selectedMinGradeIndex!;
      _selectedMinGradeIndex = _selectedMaxGradeIndex;
      _selectedMaxGradeIndex = temp;
    }

    if (_selectedMinGradeIndex == 0 &&
        _selectedMaxGradeIndex == gradeScale.length - 1) {
      _selectedMinGradeIndex = null;
      _selectedMaxGradeIndex = null;
    }
  }

  // Apply all filters and sorting
  void _applyFiltersAndSort() {
    _applyClientSideFilters();
    _sortRoutes();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private method to sort routes based on the selected sort option
  void _sortRoutes() {
    sortRoutesInPlace(_currentRoutes, _selectedSort);
  }

  // Helper method to get color for a specific grade
  String? getGradeColor(String grade) {
    return _gradeColors[grade];
  }

  // Project management methods
  Future<bool> addProject(int routeId, {String? notes}) async {
    return _executeRouteAction(
      action: () => _apiService.addProject(routeId, notes: notes),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.routesOnly,
    );
  }

  // Add project (optimized for UI interactions)
  Future<bool> addProjectOptimized(int routeId, {String? notes}) async {
    return _executeRouteAction(
      action: () => _apiService.addProject(routeId, notes: notes),
      routeId: routeId,
    );
  }

  Future<bool> removeProject(int routeId) async {
    return _executeRouteAction(
      action: () => _apiService.removeProject(routeId),
      routeId: routeId,
      refreshStrategy: _ActionRefreshStrategy.routesOnly,
    );
  }

  // Remove project (optimized for UI interactions)
  Future<bool> removeProjectOptimized(int routeId) async {
    return _executeRouteAction(
      action: () => _apiService.removeProject(routeId),
      routeId: routeId,
    );
  }

  Future<List<Project>> getUserProjects() async {
    try {
      return await _apiService.getUserProjectsTyped();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Clear all cache
  void clearAllCache() {
    _apiService.clearAllCache();
  }

  /// Clear route-specific cache
  void clearRouteCache() {
    _apiService.clearRouteCache();
  }

  /// Clear user-specific cache
  void clearUserCache() {
    _apiService.clearUserCache();
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return _apiService.getCacheStats();
  }

  /// Get hold color info by ID
  Map<String, String> getHoldColorById(int holdColorId) {
    print('🔍 getHoldColorById: Looking for holdColorId=$holdColorId');
    print('🔍 getHoldColorById: _holdColors has ${_holdColors.length} items');

    if (_holdColors.isEmpty) {
      print('⚠️ getHoldColorById: _holdColors is empty, returning default');
      return {'name': 'Unknown', 'hex_code': '#808080'};
    }

    try {
      final colorObj = _holdColors.cast<Map<String, dynamic>>().firstWhere(
        (color) {
          final colorId = int.tryParse(color['id']?.toString() ?? '');
          print('🔍 Comparing: color id=$colorId vs holdColorId=$holdColorId');
          return colorId == holdColorId;
        },
        orElse: () {
          print(
              '⚠️ getHoldColorById: No match found for holdColorId=$holdColorId, returning default');
          return {
            'id': holdColorId.toString(),
            'name': 'Unknown',
            'hex_code': '#808080'
          };
        },
      );
      print('✅ getHoldColorById: Found color: $colorObj');
      return {
        'name': colorObj['name']?.toString() ?? 'Unknown',
        'hex_code': colorObj['hex_code']?.toString() ?? '#808080',
      };
    } catch (e) {
      print('❌ getHoldColorById error: $e');
      return {'name': 'Unknown', 'hex_code': '#808080'};
    }
  }

  /// Get grade info by ID
  Map<String, String> getGradeById(int? gradeId) {
    print('🔍 getGradeById: Looking for gradeId=$gradeId');
    print(
        '🔍 getGradeById: _gradeDefinitions has ${_gradeDefinitions.length} items');

    if (gradeId == null) {
      print('⚠️ getGradeById: gradeId is null, returning default');
      return {'french_name': 'Unknown', 'color': '#808080'};
    }

    if (_gradeDefinitions.isEmpty) {
      print('⚠️ getGradeById: _gradeDefinitions is empty, returning default');
      return {'french_name': 'Unknown', 'color': '#808080'};
    }

    try {
      final gradeObj =
          _gradeDefinitions.cast<Map<String, dynamic>>().firstWhere(
        (grade) {
          final gId = int.tryParse(grade['id']?.toString() ?? '');
          print('🔍 Comparing: grade id=$gId vs gradeId=$gradeId');
          return gId == gradeId;
        },
        orElse: () {
          print(
              '⚠️ getGradeById: No match found for gradeId=$gradeId, returning default');
          return {
            'id': gradeId.toString(),
            'french_name': 'Unknown',
            'color': '#808080'
          };
        },
      );
      print('✅ getGradeById: Found grade: $gradeObj');
      return {
        'french_name': gradeObj['french_name']?.toString() ?? 'Unknown',
        'color': gradeObj['color']?.toString() ?? '#808080',
      };
    } catch (e) {
      print('❌ getGradeById error: $e');
      return {'french_name': 'Unknown', 'color': '#808080'};
    }
  }

  /// Populate route information (colors and grades) for routes after loading
  void _populateRouteData() {
    print('🔧 _populateRouteData: Processing ${_routes.length} routes');
    print(
        '🔧 _populateRouteData: _holdColors has ${_holdColors.length} colors');
    print(
        '🔧 _populateRouteData: _gradeDefinitions has ${_gradeDefinitions.length} grades');

    // Debug: print first few hold colors
    if (_holdColors.isNotEmpty) {
      print('🔧 _populateRouteData: First hold color: ${_holdColors.first}');
    }
    if (_gradeDefinitions.isNotEmpty) {
      print(
          '🔧 _populateRouteData: First grade definition: ${_gradeDefinitions.first}');
    }

    for (int i = 0; i < _routes.length; i++) {
      final route = _routes[i];
      print(
          '🔧 Processing route $i: id=${route.id}, name=${route.name}, holdColorId=${route.holdColorId}, gradeId=${route.gradeId}');

      try {
        _routes[i] = _populateRouteDataForSingleRoute(route);
        print('✅ Route $i processed successfully');
      } catch (e) {
        print('❌ Error processing route $i (${route.name}): $e');
        print(
            '❌ Route details: holdColorId=${route.holdColorId}, gradeId=${route.gradeId}');
        rethrow;
      }
    }
  }

  Future<void> _hydrateUnnamedRoutesWithNameProposals(
      {bool forceRefresh = false}) async {
    if (!_nameProposalsEndpointAvailable) {
      return;
    }

    final unnamedRoutes = _routes
        .where(
            (route) => route.name == 'Unnamed' && route.nameProposals == null)
        .toList();

    if (unnamedRoutes.isEmpty) {
      return;
    }

    for (final route in unnamedRoutes) {
      if (!_nameProposalsEndpointAvailable) {
        break;
      }

      final hydratedRoute = await _hydrateRouteNameProposals(
        route,
        forceRefresh: forceRefresh,
      );

      for (int i = 0; i < _routes.length; i++) {
        if (_routes[i].id == hydratedRoute.id) {
          _routes[i] = hydratedRoute;
          break;
        }
      }
    }
  }

  Future<Route> _hydrateRouteNameProposals(Route route,
      {bool forceRefresh = false}) async {
    if (!_nameProposalsEndpointAvailable) {
      return route;
    }

    if (route.name != 'Unnamed') {
      return route;
    }

    if (route.nameProposals != null) {
      return route;
    }

    try {
      final proposals = await _apiService.getRouteNameProposals(
        route.id,
        forceRefresh: forceRefresh,
      );

      _nameProposalsEndpointAvailable = true;

      if (proposals.isEmpty) {
        return route;
      }

      return _copyRouteWithNameProposals(route, proposals);
    } catch (e) {
      _nameProposalsEndpointAvailable = false;
      print('⚠️ Disabling route name proposal hydration after API failure: $e');
      return route;
    }
  }

  Route _copyRouteWithNameProposals(Route route, List<NameProposal> proposals) {
    return Route(
      id: route.id,
      name: route.name,
      gradeId: route.gradeId,
      gradeName: route.gradeName,
      gradeColor: route.gradeColor,
      image: route.image,
      routeSetter: route.routeSetter,
      wallSection: route.wallSection,
      lane: route.lane,
      laneName: route.laneName,
      holdColorId: route.holdColorId,
      colorName: route.colorName,
      colorHex: route.colorHex,
      description: route.description,
      createdAt: route.createdAt,
      likesCount: route.likesCount,
      commentsCount: route.commentsCount,
      gradeProposalsCount: route.gradeProposalsCount,
      warningsCount: route.warningsCount,
      ticksCount: route.ticksCount,
      projectsCount: route.projectsCount,
      likes: route.likes,
      comments: route.comments,
      gradeProposals: route.gradeProposals,
      warnings: route.warnings,
      ticks: route.ticks,
      nameProposals: proposals,
    );
  }

  /// Populate route information (colors and grades) for a single route
  Route _populateRouteDataForSingleRoute(Route route) {
    // Get color information
    final colorInfo = getHoldColorById(route.holdColorId);

    // Get grade information
    final gradeInfo = getGradeById(route.gradeId);

    // Create a new route with populated information
    return Route(
      id: route.id,
      name: route.name,
      gradeId: route.gradeId,
      gradeName: gradeInfo['french_name'],
      gradeColor: gradeInfo['color'],
      image: route.image,
      routeSetter: route.routeSetter,
      wallSection: route.wallSection,
      lane: route.lane,
      laneName: route.laneName,
      holdColorId: route.holdColorId,
      colorName: colorInfo['name'],
      colorHex: colorInfo['hex_code'],
      description: route.description,
      createdAt: route.createdAt,
      likesCount: route.likesCount,
      commentsCount: route.commentsCount,
      gradeProposalsCount: route.gradeProposalsCount,
      warningsCount: route.warningsCount,
      ticksCount: route.ticksCount,
      projectsCount: route.projectsCount,
      likes: route.likes,
      comments: route.comments,
      gradeProposals: route.gradeProposals,
      warnings: route.warnings,
      ticks: route.ticks,
      nameProposals: route.nameProposals,
    );
  }
}
