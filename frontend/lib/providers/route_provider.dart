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
          // TODO: CHECK IF THIS IS WORKING!
          .where((route) => route.gradeName == _selectedGrade)
          .toList();
    }

    // Filter by lane
    if (_selectedLane != null) {
      print(
          '🔍 Filtering by lane ID: $_selectedLane (type: ${_selectedLane.runtimeType})');
      print(
          '🔍 Route lanes before filtering: ${filteredRoutes.map((r) => '${r.name}: ${r.lane} (${r.lane.runtimeType})').take(10).toList()}');
      print(
          '🔍 Available lanes: ${_lanes.map((l) => 'ID:${l.id} Name:${l.name}').toList()}');

      // Show detailed comparison for debugging
      print('🔍 Detailed route lane comparison:');
      for (final route in filteredRoutes.take(5)) {
        final routeLane = route.lane;
        final selectedLane = _selectedLane!;
        final matches = routeLane == selectedLane;
        print(
            '  Route "${route.name}": lane=$routeLane (${routeLane.runtimeType}) == $selectedLane (${selectedLane.runtimeType}) ? $matches');
      }

      // Filter directly by lane ID (ensure both are integers)
      filteredRoutes = filteredRoutes.where((route) {
        final routeLane = route.lane;
        final selectedLane = _selectedLane!;
        return routeLane == selectedLane;
      }).toList();
      print('🔍 Routes after lane filtering: ${filteredRoutes.length}');
      if (filteredRoutes.isNotEmpty) {
        print(
            '🔍 Filtered routes: ${filteredRoutes.map((r) => r.name).take(5).toList()}');
      }
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

  // Like/Unlike route
  Future<bool> toggleLike(int routeId) async {
    try {
      final currentUser = _authProvider.currentUser;
      if (currentUser == null) return false;

      bool status = await getUserLikeStatus(routeId);

      final isLiked = status;

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

  // Like/Unlike route (optimized for UI interactions)
  Future<bool> toggleLikeOptimized(int routeId) async {
    try {
      final currentUser = _authProvider.currentUser;
      if (currentUser == null) return false;

      bool status = await getUserLikeStatus(routeId);

      final isLiked = status;

      if (isLiked) {
        await _apiService.unlikeRoute(routeId);
      } else {
        await _apiService.likeRoute(routeId);
      }

      // Don't reload everything - let the UI handle its own state updates
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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

  // Add attempts to a route (optimized for UI interactions)
  Future<bool> addAttemptsOptimized(int routeId, int attempts,
      {String? notes, String? attemptType}) async {
    try {
      await _apiService.addAttempts(routeId, attempts,
          notes: notes, attemptType: attemptType);

      // Don't reload everything - let the UI handle its own state updates
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

  // Mark a route as sent in a specific style (optimized for UI interactions)
  Future<bool> markSendOptimized(int routeId, String sendType,
      {String? notes}) async {
    try {
      await _apiService.markSend(routeId, sendType, notes: notes);

      // Don't reload everything - let the UI handle its own state updates
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove a specific send type from a route
  Future<bool> unmarkSend(int routeId, String sendType) async {
    try {
      await _apiService.unmarkSend(routeId, sendType);

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

  // Remove a specific send type from a route (optimized for UI interactions)
  Future<bool> unmarkSendOptimized(int routeId, String sendType) async {
    try {
      await _apiService.unmarkSend(routeId, sendType);

      // Don't reload everything - let the UI handle its own state updates
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update route notes without affecting attempts or sends
  Future<bool> updateRouteNotes(int routeId, String notes) async {
    try {
      await _apiService.updateRouteNotes(routeId, notes);

      // Don't reload everything - let the UI handle its own state updates
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

  // Add comment (optimized for UI interactions)
  Future<bool> addCommentOptimized(int routeId, String content) async {
    try {
      await _apiService.addComment(routeId, content);
      // Only refresh the specific route if it's currently selected to show new comment
      if (_selectedRoute?.id == routeId) {
        await loadRoute(routeId);
      }
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

  // Propose grade (optimized for UI interactions)
  Future<bool> proposeGradeOptimized(
    int routeId,
    String proposedGrade,
    String? reasoning,
  ) async {
    try {
      await _apiService.proposeGrade(routeId, proposedGrade, reasoning ?? '');
      // Only refresh the specific route if it's currently selected to show new proposal
      if (_selectedRoute?.id == routeId) {
        await loadRoute(routeId);
      }
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

  // Add warning (optimized for UI interactions)
  Future<bool> addWarningOptimized(
    int routeId,
    String warningType,
    String description,
  ) async {
    try {
      await _apiService.addWarning(routeId, warningType, description);
      // Only refresh the specific route if it's currently selected to show new warning
      if (_selectedRoute?.id == routeId) {
        await loadRoute(routeId);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
    print('Setting lane filter to: $lane');
    print(
        '🔍 Available lanes: ${_lanes.map((l) => 'ID:${l.id} Name:${l.name}').toList()}');
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
        _currentRoutes.sort((a, b) => a.gradeId.compareTo(b.gradeId));
        break;
      case SortOption.gradeDesc:
        _currentRoutes.sort((a, b) => b.gradeId.compareTo(a.gradeId));
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

  // Add project (optimized for UI interactions)
  Future<bool> addProjectOptimized(int routeId, {String? notes}) async {
    try {
      await _apiService.addProject(routeId, notes: notes);
      // Don't reload everything - let the UI handle its own state updates
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

  // Remove project (optimized for UI interactions)
  Future<bool> removeProjectOptimized(int routeId) async {
    try {
      await _apiService.removeProject(routeId);
      // Don't reload everything - let the UI handle its own state updates
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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

  /// Get hold color info by ID
  Map<String, String> getHoldColorById(int holdColorId) {
    final colorObj = _holdColors.firstWhere(
      (color) => int.parse(color['id']) == holdColorId,
    );
    return {
      'name': colorObj['name']?.toString() ?? '',
      'hex_code': colorObj['hex_code']?.toString() ?? '',
    };
  }

  /// Get grade info by ID
  Map<String, String> getGradeById(int? gradeId) {
    final gradeObj = _gradeDefinitions.firstWhere(
      (grade) => int.parse(grade['id']) == gradeId,
    );
    return {
      'french_name': gradeObj['french_name']?.toString() ?? '',
      'color': gradeObj['color']?.toString() ?? '',
    };
  }

  /// Populate route information (colors and grades) for routes after loading
  void _populateRouteData() {
    for (int i = 0; i < _routes.length; i++) {
      final route = _routes[i];

      _routes[i] = _populateRouteDataForSingleRoute(route);
    }
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
    );
  }
}
