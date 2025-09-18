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
  ProfileTimeFilter _timeFilter = ProfileTimeFilter.all;

  // Separate notifiers for specific concerns
  final ValueNotifier<ProfileTimeFilter> timeFilterNotifier =
      ValueNotifier(ProfileTimeFilter.all);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  // Getters
  List<UserTick> get userTicks => _userTicks;
  List<UserLike> get userLikes => _userLikes;
  List<Project> get userProjects => _userProjects;
  List<GradeStatistics> get gradeStats => _gradeStats;
  ProfileStats? get profileStats => _profileStats;
  bool get isLoading => loadingNotifier.value;
  String? get error => errorNotifier.value;
  ProfileTimeFilter get timeFilter => timeFilterNotifier.value;

  // Filtered getters based on time filter
  List<UserTick> get filteredTicks {
    final startDate = _timeFilter.startDate;
    if (startDate == null) return _userTicks;
    return _userTicks
        .where((tick) => tick.updatedAt.isAfter(startDate))
        .toList();
  }

  // New getter for lead sends only
  List<UserTick> get filteredLeadSends {
    final startDate = _timeFilter.startDate;
    final baseTicks = startDate == null
        ? _userTicks
        : _userTicks
            .where((tick) => tick.createdAt.isAfter(startDate))
            .toList();

    return baseTicks.where((tick) => tick.leadSend).toList();
  }

  // New getter for routes in progress (attempts without lead send)
  List<UserTick> get filteredInProgressRoutes {
    final startDate = _timeFilter.startDate;
    final baseTicks = startDate == null
        ? _userTicks
        : _userTicks
            .where((tick) => tick.createdAt.isAfter(startDate))
            .toList();

    return baseTicks
        .where((tick) =>
            (tick.topRopeAttempts > 0 || tick.leadAttempts > 0) &&
            !tick.leadSend)
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

      return GradeStatistics(grade: grade, ticks: ticks);
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
    timeFilterNotifier.value = filter;
    // Don't call notifyListeners() here - only specific consumers should rebuild
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    _setLoading(true);
    errorNotifier.value = null;

    try {
      await Future.wait([
        _loadUserTicks(forceRefresh: forceRefresh),
        _loadUserLikes(forceRefresh: forceRefresh),
        _loadUserProjects(forceRefresh: forceRefresh),
      ]);

      _calculateGradeStats();
    } catch (e) {
      errorNotifier.value = 'Failed to load profile: $e';
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

  void _calculateGradeStats() {
    final gradeTicksMap = <String, List<UserTick>>{};

    for (final tick in _userTicks) {
      gradeTicksMap.putIfAbsent(tick.routeGrade, () => []).add(tick);
    }

    _gradeStats = gradeTicksMap.entries.map((entry) {
      final grade = entry.key;
      final ticks = entry.value;

      return GradeStatistics(
        grade: grade,
        ticks: ticks,
      );
    }).toList()
      ..sort(
        (a, b) => _gradeOrder(a.grade).compareTo(_gradeOrder(b.grade)),
      );

    // Recalculate profile stats from frontend data
    _calculateProfileStats();
  }

  void _calculateProfileStats() {
    // Calculate all statistics from frontend data
    final totalLikes = _userLikes.length;
    final totalProjects = _userProjects.length;

    // Send statistics
    final topRopeSends = _userTicks.where((tick) => tick.topRopeSend).length;
    final leadSends = _userTicks.where((tick) => tick.leadSend).length;

    // Flash statistics
    final topRopeFlashes = _userTicks
        .where((tick) => tick.topRopeAttempts == 0 && tick.topRopeSend)
        .length;
    final leadFlashes = _userTicks
        .where((tick) => tick.leadAttempts == 0 && tick.leadSend)
        .length;

    // Grade achievements
    final grades = _userTicks.map((tick) => tick.routeGrade).toSet().toList();
    String? hardestGrade;
    String? hardestTopRopeGrade;
    String? hardestLeadGrade;

    if (grades.isNotEmpty) {
      // Sort grades to find hardest overall
      grades.sort((a, b) {
        final aOrder = _gradeOrder(a);
        final bOrder = _gradeOrder(b);
        return bOrder.compareTo(aOrder); // Descending order for hardest first
      });
      hardestGrade = grades.first;

      // Find hardest top rope grade
      final topRopeGrades = _userTicks
          .where((tick) => tick.topRopeSend)
          .map((tick) => tick.routeGrade)
          .toSet()
          .toList();
      if (topRopeGrades.isNotEmpty) {
        topRopeGrades.sort((a, b) => _gradeOrder(b).compareTo(_gradeOrder(a)));
        hardestTopRopeGrade = topRopeGrades.first;
      }

      // Find hardest lead grade
      final leadGrades = _userTicks
          .where((tick) => tick.leadSend)
          .map((tick) => tick.routeGrade)
          .toSet()
          .toList();
      if (leadGrades.isNotEmpty) {
        leadGrades.sort((a, b) => _gradeOrder(b).compareTo(_gradeOrder(a)));
        hardestLeadGrade = leadGrades.first;
      }
    }

    // Achieved grades (sorted by difficulty)
    final achievedGrades = grades
      ..sort((a, b) => _gradeOrder(a).compareTo(_gradeOrder(b)));

    _profileStats = ProfileStats(
      totalLikes: totalLikes,
      totalComments: 0, // Comments not tracked in frontend
      totalProjects: totalProjects,
      topRopeAttempts:
          _userTicks.fold<int>(0, (sum, tick) => sum + tick.topRopeAttempts),
      leadAttempts:
          _userTicks.fold<int>(0, (sum, tick) => sum + tick.leadAttempts),
      topRopeSends: topRopeSends,
      leadSends: leadSends,
      topRopeFlashes: topRopeFlashes,
      leadFlashes: leadFlashes,
      hardestGrade: hardestGrade,
      hardestTopRopeGrade: hardestTopRopeGrade,
      hardestLeadGrade: hardestLeadGrade,
      achievedGrades: achievedGrades,
    );
  }

  void _setLoading(bool loading) {
    loadingNotifier.value = loading;
    notifyListeners();
  }

  void clearError() {
    errorNotifier.value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    timeFilterNotifier.dispose();
    loadingNotifier.dispose();
    errorNotifier.dispose();
    super.dispose();
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
