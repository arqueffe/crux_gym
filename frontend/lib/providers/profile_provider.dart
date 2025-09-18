import 'package:flutter/foundation.dart';
import '../models/profile_models.dart';
import '../models/route_models.dart';
import '../services/cached_api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';

class ProfileProvider extends ChangeNotifier {
  late final CachedApiService _apiService;
  final RouteProvider? _routeProvider;

  ProfileProvider({
    required AuthProvider authProvider,
    RouteProvider? routeProvider,
  }) : _routeProvider = routeProvider {
    _apiService = CachedApiService(authProvider: authProvider);
  }

  List<UserTick> _userTicks = [];
  List<UserLike> _userLikes = [];
  List<Project> _userProjects = [];
  List<GradeStatistics> _gradeStats = [];
  ProfileStats? _profileStats;
  bool _isLoading = false;
  String? _error;
  ProfileTimeFilter _timeFilter = ProfileTimeFilter.all;

  // Getters
  List<UserTick> get userTicks => _userTicks;
  List<UserLike> get userLikes => _userLikes;
  List<Project> get userProjects => _userProjects;
  List<GradeStatistics> get gradeStats => _gradeStats;
  ProfileStats? get profileStats => _profileStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProfileTimeFilter get timeFilter => _timeFilter;

  // Filtered getters based on time filter
  List<UserTick> get filteredTicks {
    final startDate = _timeFilter.startDate;
    if (startDate == null) return _userTicks;
    return _userTicks
        .where((tick) => tick.createdAt.isAfter(startDate))
        .toList();
  }

  List<UserLike> get filteredLikes {
    final startDate = _timeFilter.startDate;
    if (startDate == null) return _userLikes;
    return _userLikes
        .where((like) => like.createdAt.isAfter(startDate))
        .toList();
  }

  List<Project> get filteredProjects {
    final startDate = _timeFilter.startDate;
    if (startDate == null) return _userProjects;
    return _userProjects
        .where((project) => project.createdAt.isAfter(startDate))
        .toList();
  }

  List<GradeStatistics> get filteredGradeStats {
    final startDate = _timeFilter.startDate;
    if (startDate == null) return _gradeStats;

    // Recalculate grade stats for filtered period
    final filteredTicksMap = <String, List<UserTick>>{};

    for (final tick in filteredTicks) {
      filteredTicksMap.putIfAbsent(tick.routeGrade, () => []).add(tick);
    }

    return filteredTicksMap.entries.map((entry) {
      final grade = entry.key;
      final ticks = entry.value;
      final tickCount = ticks.length;
      final totalAttempts = ticks.fold<int>(
        0,
        (sum, tick) => sum + tick.attempts,
      );
      final flashCount = ticks.where((tick) => tick.flash).length;
      final averageAttempts = tickCount > 0 ? totalAttempts / tickCount : 0.0;
      final flashRate = tickCount > 0 ? flashCount / tickCount : 0.0;

      return GradeStatistics(
        grade: grade,
        tickCount: tickCount,
        totalAttempts: totalAttempts,
        flashCount: flashCount,
        averageAttempts: averageAttempts,
        flashRate: flashRate,
      );
    }).toList()
      ..sort((a, b) => _gradeOrder(a.grade).compareTo(_gradeOrder(b.grade)));
  }

  int _gradeOrder(String grade) {
    // Use route provider's grade definitions if available
    if (_routeProvider != null && _routeProvider!.gradeDefinitions.isNotEmpty) {
      for (final gradeDefinition in _routeProvider!.gradeDefinitions) {
        if (gradeDefinition['french_name'] == grade) {
          final value = gradeDefinition['value'];
          if (value is String) {
            return double.tryParse(value)?.toInt() ?? 0;
          } else if (value is num) {
            return value.toInt();
          }
        }
      }
    }

    // Fallback to simple V-scale ordering for backwards compatibility
    if (grade.startsWith('V')) {
      final number = int.tryParse(grade.substring(1));
      return number ?? 0;
    }
    return 0;
  }

  void setTimeFilter(ProfileTimeFilter filter) {
    _timeFilter = filter;
    notifyListeners();
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _loadUserTicks(forceRefresh: forceRefresh),
        _loadUserLikes(forceRefresh: forceRefresh),
        _loadUserProjects(forceRefresh: forceRefresh),
        _loadProfileStats(forceRefresh: forceRefresh),
      ]);

      _calculateGradeStats();
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserTicks({bool forceRefresh = false}) async {
    try {
      final data = await _apiService.getUserTicks(forceRefresh: forceRefresh);
      _userTicks = data.map((json) => UserTick.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to load user ticks: $e';
    }
  }

  Future<void> _loadUserLikes({bool forceRefresh = false}) async {
    try {
      final data = await _apiService.getUserLikes(forceRefresh: forceRefresh);
      _userLikes = data.map((json) => UserLike.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to load user likes: $e';
    }
  }

  Future<void> _loadUserProjects({bool forceRefresh = false}) async {
    try {
      final data = await _apiService.getUserProjects(
        forceRefresh: forceRefresh,
      );
      _userProjects = data.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to load user projects: $e';
    }
  }

  Future<void> _loadProfileStats({bool forceRefresh = false}) async {
    try {
      final data = await _apiService.getUserStats(forceRefresh: forceRefresh);
      _profileStats = ProfileStats.fromJson(data);
    } catch (e) {
      throw 'Failed to load profile stats: $e';
    }
  }

  void _calculateGradeStats() {
    final gradeTicksMap = <String, List<UserTick>>{};

    for (final tick in _userTicks) {
      gradeTicksMap.putIfAbsent(tick.routeGrade, () => []).add(tick);
    }

    _gradeStats = gradeTicksMap.entries.map((entry) {
      final grade = entry.key;
      final ticks = entry.value;
      final tickCount = ticks.length;
      final totalAttempts = ticks.fold<int>(
        0,
        (sum, tick) => sum + tick.attempts,
      );
      final flashCount = ticks.where((tick) => tick.flash).length;
      final averageAttempts = tickCount > 0 ? totalAttempts / tickCount : 0.0;
      final flashRate = tickCount > 0 ? flashCount / tickCount : 0.0;

      return GradeStatistics(
        grade: grade,
        tickCount: tickCount,
        totalAttempts: totalAttempts,
        flashCount: flashCount,
        averageAttempts: averageAttempts,
        flashRate: flashRate,
      );
    }).toList()
      ..sort(
        (a, b) => _gradeOrder(a.grade).compareTo(_gradeOrder(b.grade)),
      );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadProfile(forceRefresh: true);
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
