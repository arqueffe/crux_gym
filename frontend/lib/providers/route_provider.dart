import 'package:flutter/foundation.dart';
import '../models/route_models.dart';
import '../services/api_service.dart';

class RouteProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Route> _routes = [];
  Route? _selectedRoute;
  bool _isLoading = false;
  String? _error;
  String? _selectedWallSection;
  String? _selectedGrade;
  List<String> _wallSections = [];
  List<String> _grades = [];

  // Getters
  List<Route> get routes => _routes;
  Route? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedWallSection => _selectedWallSection;
  String? get selectedGrade => _selectedGrade;
  List<String> get wallSections => _wallSections;
  List<String> get grades => _grades;

  // Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadRoutes(),
      loadWallSections(),
      loadGrades(),
    ]);
  }

  // Load routes with optional filtering
  Future<void> loadRoutes() async {
    _setLoading(true);
    try {
      _routes = await _apiService.getRoutes(
        wallSection: _selectedWallSection,
        grade: _selectedGrade,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Load specific route with details
  Future<void> loadRoute(int routeId) async {
    _setLoading(true);
    try {
      _selectedRoute = await _apiService.getRoute(routeId);
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
  Future<bool> toggleLike(int routeId, String userName) async {
    try {
      final route = _routes.firstWhere((r) => r.id == routeId);
      final isLiked =
          route.likes?.any((like) => like.userName == userName) ?? false;

      if (isLiked) {
        await _apiService.unlikeRoute(routeId, userName);
      } else {
        await _apiService.likeRoute(routeId, userName);
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

  // Add comment
  Future<bool> addComment(int routeId, String userName, String content) async {
    try {
      await _apiService.addComment(routeId, userName, content);
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
    String userName,
    String proposedGrade,
    String? reasoning,
  ) async {
    try {
      await _apiService.proposeGrade(
          routeId, userName, proposedGrade, reasoning);
      // Refresh the route to show new proposal
      await loadRoute(routeId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add warning
  Future<bool> addWarning(
    int routeId,
    String userName,
    String warningType,
    String description,
  ) async {
    try {
      await _apiService.addWarning(routeId, userName, warningType, description);
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
  Future<void> loadWallSections() async {
    try {
      _wallSections = await _apiService.getWallSections();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load grades
  Future<void> loadGrades() async {
    try {
      _grades = await _apiService.getGrades();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Filter methods
  void setWallSectionFilter(String? wallSection) {
    _selectedWallSection = wallSection;
    loadRoutes();
  }

  void setGradeFilter(String? grade) {
    _selectedGrade = grade;
    loadRoutes();
  }

  void clearFilters() {
    _selectedWallSection = null;
    _selectedGrade = null;
    loadRoutes();
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
}
