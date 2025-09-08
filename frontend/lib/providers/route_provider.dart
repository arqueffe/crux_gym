import 'package:flutter/foundation.dart';
import '../models/route_models.dart';
import '../models/lane_models.dart';
import '../services/cached_api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/filter_drawer.dart';

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
  String? _selectedWallSection;
  String? _selectedGrade;
  int? _selectedLane;
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

  // Getters
  List<Route> get routes => _currentRoutes;
  Route? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedWallSection => _selectedWallSection;
  String? get selectedGrade => _selectedGrade;
  int? get selectedLane => _selectedLane;
  String? get selectedRouteSetter => _selectedRouteSetter;
  List<String> get wallSections => _wallSections;
  List<String> get grades => _grades;
  List<Lane> get lanes => _lanes;
  List<int> get laneNumbers => _lanes.map((lane) => lane.number).toList();
  List<String> get routeSetters => _routeSetters;
  List<Map<String, dynamic>> get gradeDefinitions => _gradeDefinitions;
  List<Map<String, dynamic>> get holdColors => _holdColors;
  Map<String, String> get gradeColors => _gradeColors;
  SortOption get selectedSort => _selectedSort;
  FilterState get tickedFilter => _tickedFilter;
  FilterState get likedFilter => _likedFilter;
  FilterState get warnedFilter => _warnedFilter;
  FilterState get projectFilter => _projectFilter;

  bool get hasActiveFilters =>
      _selectedWallSection != null ||
      _selectedGrade != null ||
      _selectedLane != null ||
      _selectedRouteSetter != null ||
      _tickedFilter != FilterState.all ||
      _likedFilter != FilterState.all ||
      _warnedFilter != FilterState.all ||
      _projectFilter != FilterState.all;

  // Load initial data
  Future<void> loadInitialData({bool forceRefresh = false}) async {
    await Future.wait([
      loadRoutes(forceRefresh: forceRefresh),
      loadWallSections(forceRefresh: forceRefresh),
      loadGrades(forceRefresh: forceRefresh),
      loadLanes(forceRefresh: forceRefresh),
      loadRouteSetters(),
      loadGradeDefinitions(forceRefresh: forceRefresh),
      loadHoldColors(forceRefresh: forceRefresh),
      loadGradeColors(forceRefresh: forceRefresh),
    ]);
  }

  // Load routes with optional filtering
  Future<void> loadRoutes({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      // Always fetch all routes first to ensure we have the complete dataset
      _routes = await _apiService.getRoutes(forceRefresh: forceRefresh);

      // Apply client-side filters
      _applyClientSideFilters();

      // Apply sorting
      _sortRoutes();

      // Update route setters list after loading routes
      await loadRouteSetters();

      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Refresh routes while preserving current filters
  Future<void> refreshRoutes({bool forceRefresh = false}) async {
    await loadRoutes(forceRefresh: forceRefresh);
  }

  // Apply client-side filters (for features not supported by API)
  void _applyClientSideFilters() {
    List<Route> filteredRoutes = List.from(_routes);

    // Filter by wall section
    if (_selectedWallSection != null) {
      filteredRoutes = filteredRoutes
          .where((route) => route.wallSection == _selectedWallSection)
          .toList();
    }

    // Filter by grade
    if (_selectedGrade != null) {
      filteredRoutes = filteredRoutes
          .where((route) => route.grade == _selectedGrade)
          .toList();
    }

    // Filter by lane
    if (_selectedLane != null) {
      filteredRoutes =
          filteredRoutes.where((route) => route.lane == _selectedLane).toList();
    }

    // Filter by route setter
    if (_selectedRouteSetter != null) {
      filteredRoutes = filteredRoutes
          .where((route) => route.routeSetter == _selectedRouteSetter)
          .toList();
    }

    // Filter by ticked status (assuming we have user context)
    if (_tickedFilter != FilterState.all) {
      if (_tickedFilter == FilterState.only) {
        filteredRoutes = filteredRoutes
            .where((route) => route.ticksCount > 0) // Show only ticked routes
            .toList();
      } else if (_tickedFilter == FilterState.exclude) {
        filteredRoutes = filteredRoutes
            .where(
                (route) => route.ticksCount == 0) // Show only non-ticked routes
            .toList();
      }
    }

    // Filter by liked status (assuming we have user context)
    if (_likedFilter != FilterState.all) {
      if (_likedFilter == FilterState.only) {
        filteredRoutes = filteredRoutes
            .where((route) => route.likesCount > 0) // Show only liked routes
            .toList();
      } else if (_likedFilter == FilterState.exclude) {
        filteredRoutes = filteredRoutes
            .where(
                (route) => route.likesCount == 0) // Show only non-liked routes
            .toList();
      }
    }

    // Filter by warned status
    if (_warnedFilter != FilterState.all) {
      if (_warnedFilter == FilterState.only) {
        filteredRoutes = filteredRoutes
            .where(
                (route) => route.warningsCount > 0) // Show only warned routes
            .toList();
      } else if (_warnedFilter == FilterState.exclude) {
        filteredRoutes = filteredRoutes
            .where((route) =>
                route.warningsCount == 0) // Show only non-warned routes
            .toList();
      }
    }

    // Filter by project status
    if (_projectFilter != FilterState.all) {
      if (_projectFilter == FilterState.only) {
        filteredRoutes = filteredRoutes
            .where(
                (route) => route.projectsCount > 0) // Show only project routes
            .toList();
      } else if (_projectFilter == FilterState.exclude) {
        filteredRoutes = filteredRoutes
            .where((route) =>
                route.projectsCount == 0) // Show only non-project routes
            .toList();
      }
    }

    _currentRoutes = filteredRoutes;
  }

  // Load specific route with details
  Future<void> loadRoute(int routeId, {bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      _selectedRoute =
          await _apiService.getRoute(routeId, forceRefresh: forceRefresh);
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

  // Like/Unlike route
  Future<bool> toggleLike(int routeId) async {
    try {
      // First, refresh the route data to get the current like status
      await loadRoute(routeId);

      final route =
          _selectedRoute ?? _routes.firstWhere((r) => r.id == routeId);
      final currentUser = _authProvider.currentUser;
      if (currentUser == null) return false;

      final isLiked =
          route.likes?.any((like) => like.userId == currentUser.id) ?? false;

      if (isLiked) {
        await _apiService.unlikeRoute(routeId);
      } else {
        await _apiService.likeRoute(routeId);
      }

      // Refresh the specific route to get updated data
      await loadRoute(routeId);
      // Also refresh the routes list
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Tick/Untick route
  Future<bool> toggleTick(
    int routeId, {
    int attempts = 1,
    bool flash = false,
    String? notes,
  }) async {
    try {
      // Check if route is already ticked
      final tickStatus = await _apiService.getUserTick(routeId);
      final isTicked = tickStatus['ticked'] ?? false;

      if (isTicked) {
        await _apiService.untickRoute(routeId);
      } else {
        await _apiService.tickRoute(
          routeId,
          attempts: attempts,
          flash: flash,
          notes: notes,
        );
      }

      // Refresh the specific route to get updated data
      if (_selectedRoute?.id == routeId) {
        await loadRoute(routeId);
      }
      // Also refresh the routes list
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add attempts to a route
  Future<bool> addAttempts(int routeId, int attempts, {String? notes}) async {
    try {
      await _apiService.addAttempts(routeId, attempts, notes: notes);

      // Refresh the specific route to get updated data
      if (_selectedRoute?.id == routeId) {
        await loadRoute(routeId);
      }
      // Also refresh the routes list
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark a route as sent in a specific style
  Future<bool> markSend(int routeId, String sendType, {String? notes}) async {
    try {
      await _apiService.markSend(routeId, sendType, notes: notes);

      // Refresh the specific route to get updated data
      if (_selectedRoute?.id == routeId) {
        await loadRoute(routeId);
      }
      // Also refresh the routes list
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
    try {
      await _apiService.addComment(routeId, content);
      // Refresh the route to show new comment
      await loadRoute(routeId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Propose grade
  Future<bool> proposeGrade(
    int routeId,
    String proposedGrade,
    String? reasoning,
  ) async {
    try {
      await _apiService.proposeGrade(routeId, proposedGrade, reasoning ?? '');
      // Refresh the route to show new proposal
      await loadRoute(routeId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
    try {
      await _apiService.addWarning(routeId, warningType, description);
      // Refresh the route to show new warning
      await loadRoute(routeId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load wall sections
  Future<void> loadWallSections({bool forceRefresh = false}) async {
    try {
      _wallSections =
          await _apiService.getWallSections(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load grades
  Future<void> loadGrades({bool forceRefresh = false}) async {
    try {
      _grades = await _apiService.getGrades(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load lanes
  Future<void> loadLanes({bool forceRefresh = false}) async {
    try {
      _lanes = await _apiService.getLanes(forceRefresh: forceRefresh);
    } catch (e) {
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

  // Load grade definitions with colors
  Future<void> loadGradeDefinitions({bool forceRefresh = false}) async {
    try {
      _gradeDefinitions =
          await _apiService.getGradeDefinitions(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load hold colors
  Future<void> loadHoldColors({bool forceRefresh = false}) async {
    try {
      _holdColors = await _apiService.getHoldColors(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load grade colors mapping
  Future<void> loadGradeColors({bool forceRefresh = false}) async {
    try {
      _gradeColors =
          await _apiService.getGradeColors(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Filter methods
  void setWallSectionFilter(String? wallSection) {
    _selectedWallSection = wallSection;
    _applyFiltersAndSort();
  }

  void setGradeFilter(String? grade) {
    _selectedGrade = grade;
    _applyFiltersAndSort();
  }

  void setLaneFilter(int? lane) {
    _selectedLane = lane;
    _applyFiltersAndSort();
  }

  void setRouteSetterFilter(String? routeSetter) {
    _selectedRouteSetter = routeSetter;
    _applyFiltersAndSort();
  }

  void setSortOption(SortOption sortOption) {
    _selectedSort = sortOption;
    _applyFiltersAndSort();
  }

  void setTickedFilter(FilterState state) {
    _tickedFilter = state;
    _applyFiltersAndSort();
  }

  void setLikedFilter(FilterState state) {
    _likedFilter = state;
    _applyFiltersAndSort();
  }

  void setWarnedFilter(FilterState state) {
    _warnedFilter = state;
    _applyFiltersAndSort();
  }

  void setProjectFilter(FilterState state) {
    _projectFilter = state;
    _applyFiltersAndSort();
  }

  void clearFilters() {
    _selectedWallSection = null;
    _selectedGrade = null;
    _selectedLane = null;
    loadRoutes();
  }

  void clearAllFilters() {
    _selectedWallSection = null;
    _selectedGrade = null;
    _selectedLane = null;
    _selectedRouteSetter = null;
    _tickedFilter = FilterState.all;
    _likedFilter = FilterState.all;
    _warnedFilter = FilterState.all;
    _projectFilter = FilterState.all;
    _selectedSort = SortOption.newest;
    loadRoutes();
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
    switch (_selectedSort) {
      case SortOption.newest:
        _currentRoutes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        _currentRoutes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.nameAZ:
        _currentRoutes.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameZA:
        _currentRoutes.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.gradeAsc:
        _currentRoutes.sort((a, b) => a.grade.compareTo(b.grade));
        break;
      case SortOption.gradeDesc:
        _currentRoutes.sort((a, b) => b.grade.compareTo(a.grade));
        break;
      case SortOption.mostLikes:
        _currentRoutes.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case SortOption.leastLikes:
        _currentRoutes.sort((a, b) => a.likesCount.compareTo(b.likesCount));
        break;
      case SortOption.mostComments:
        _currentRoutes
            .sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
        break;
      case SortOption.leastComments:
        _currentRoutes
            .sort((a, b) => a.commentsCount.compareTo(b.commentsCount));
        break;
      case SortOption.mostTicks:
        _currentRoutes.sort((a, b) => b.ticksCount.compareTo(a.ticksCount));
        break;
      case SortOption.leastTicks:
        _currentRoutes.sort((a, b) => a.ticksCount.compareTo(b.ticksCount));
        break;
    }
  }

  // Helper method to get color for a specific grade
  String? getGradeColor(String grade) {
    return _gradeColors[grade];
  }

  // Project management methods
  Future<bool> addProject(int routeId, {String? notes}) async {
    try {
      await _apiService.addProject(routeId, notes: notes);
      // Reload routes to update project counts
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProject(int routeId) async {
    try {
      await _apiService.removeProject(routeId);
      // Reload routes to update project counts
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProjectStatus(int routeId) async {
    try {
      return await _apiService.getProjectStatus(routeId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
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
}
