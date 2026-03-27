import 'package:flutter/foundation.dart';
import '../models/profile_models.dart';
import '../models/route_models.dart';
import '../services/cached_api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../utils/grade_sorting.dart';

class ProfileProvider extends ChangeNotifier {
  late final CachedApiService _apiService;
  final RouteProvider? _routeProvider;
  static const Duration _profileCacheTtl = Duration(seconds: 30);

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
  int _totalComments = 0;
  ProfileTimeFilter _timeFilter = ProfileTimeFilter.all;
  Future<void>? _ongoingLoad;
  DateTime? _lastLoadedAt;

  ProfileTimeFilter? _cachedFilter;
  List<UserTick>? _cachedFilteredTicks;
  List<UserLike>? _cachedFilteredLikes;
  List<Project>? _cachedFilteredProjects;
  List<GradeStatistics>? _cachedFilteredGradeStats;
  List<UserTick>? _cachedFilteredLeadSends;
  List<UserTick>? _cachedFilteredInProgressRoutes;
  String? _cachedFilteredHardestGrade;
  bool _hasCachedFilteredHardestGrade = false;
  final Map<String, double> _gradeOrderCache = <String, double>{};

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
    _ensureFilterCaches();
    return _cachedFilteredTicks!;
  }

  // New getter for lead sends only
  List<UserTick> get filteredLeadSends {
    _ensureFilterCaches();
    return _cachedFilteredLeadSends!;
  }

  // New getter for routes in progress (attempts without lead send)
  List<UserTick> get filteredInProgressRoutes {
    _ensureFilterCaches();
    return _cachedFilteredInProgressRoutes!;
  }

  List<UserLike> get filteredLikes {
    _ensureFilterCaches();
    return _cachedFilteredLikes!;
  }

  List<Project> get filteredProjects {
    _ensureFilterCaches();
    return _cachedFilteredProjects!;
  }

  List<GradeStatistics> get filteredGradeStats {
    _ensureFilterCaches();
    return _cachedFilteredGradeStats!;
  }

  String? get filteredHardestGrade {
    _ensureFilterCaches();
    return _hasCachedFilteredHardestGrade ? _cachedFilteredHardestGrade : null;
  }

  double _gradeOrder(String grade) {
    return _gradeOrderCache.putIfAbsent(
      grade,
      () => gradeOrderValue(
        grade,
        gradeDefinitions: _routeProvider?.gradeDefinitions ?? const [],
      ),
    );
  }

  void setTimeFilter(ProfileTimeFilter filter) {
    _timeFilter = filter;
    timeFilterNotifier.value = filter;
    _clearFilterCaches();
    // Don't call notifyListeners() here - only specific consumers should rebuild
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_ongoingLoad != null) {
      return _ongoingLoad!;
    }

    if (!forceRefresh && _isProfileDataFresh()) {
      return;
    }

    _ongoingLoad = _loadProfileInternal(forceRefresh: forceRefresh);
    try {
      await _ongoingLoad!;
    } finally {
      _ongoingLoad = null;
    }
  }

  Future<void> _loadProfileInternal({bool forceRefresh = false}) async {
    _setLoading(true);
    errorNotifier.value = null;

    try {
      await Future.wait([
        _loadUserTicks(forceRefresh: forceRefresh),
        _loadUserLikes(forceRefresh: forceRefresh),
        _loadUserProjects(forceRefresh: forceRefresh),
        _loadUserStats(forceRefresh: forceRefresh),
      ]);

      _calculateGradeStats();
      _lastLoadedAt = DateTime.now();
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

  Future<void> _loadUserStats({bool forceRefresh = false}) async {
    try {
      final data = await _apiService.getUserStats(forceRefresh: forceRefresh);
      _totalComments = _parseIntValue(data['total_comments']);
    } catch (_) {
      // User stats are non-blocking for profile rendering.
      _totalComments = 0;
    }
  }

  int _parseIntValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  void _calculateGradeStats() {
    _gradeOrderCache.clear();
    _clearFilterCaches();

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
    const topRopeFlashes = 0;
    final leadFlashes = _userTicks.where((tick) => tick.isLeadFlash).length;

    // Grade achievements
    final grades = _userTicks.map((tick) => tick.routeGrade).toSet().toList();
    String? hardestGrade;
    String? hardestTopRopeGrade;
    String? hardestLeadGrade;

    double? hardestGradeOrder;
    double? hardestTopRopeGradeOrder;
    double? hardestLeadGradeOrder;

    for (final tick in _userTicks) {
      final grade = tick.routeGrade;
      final order = _gradeOrder(grade);

      if (hardestGradeOrder == null || order > hardestGradeOrder) {
        hardestGradeOrder = order;
        hardestGrade = grade;
      }

      if (tick.topRopeSend &&
          (hardestTopRopeGradeOrder == null ||
              order > hardestTopRopeGradeOrder)) {
        hardestTopRopeGradeOrder = order;
        hardestTopRopeGrade = grade;
      }

      if (tick.leadSend &&
          (hardestLeadGradeOrder == null || order > hardestLeadGradeOrder)) {
        hardestLeadGradeOrder = order;
        hardestLeadGrade = grade;
      }
    }

    // Achieved grades (sorted by difficulty)
    final achievedGrades = grades
      ..sort((a, b) => _gradeOrder(a).compareTo(_gradeOrder(b)));

    _profileStats = ProfileStats(
      totalLikes: totalLikes,
      totalComments: _totalComments,
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
    _lastLoadedAt = null;
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return _apiService.getCacheStats();
  }

  bool _isProfileDataFresh() {
    if (_lastLoadedAt == null) {
      return false;
    }

    return DateTime.now().difference(_lastLoadedAt!) < _profileCacheTtl;
  }

  void _clearFilterCaches() {
    _cachedFilter = null;
    _cachedFilteredTicks = null;
    _cachedFilteredLikes = null;
    _cachedFilteredProjects = null;
    _cachedFilteredGradeStats = null;
    _cachedFilteredLeadSends = null;
    _cachedFilteredInProgressRoutes = null;
    _cachedFilteredHardestGrade = null;
    _hasCachedFilteredHardestGrade = false;
  }

  void _ensureFilterCaches() {
    if (_cachedFilter == _timeFilter && _cachedFilteredTicks != null) {
      return;
    }

    final startDate = _timeFilter.startDate;
    final ticks = startDate == null
        ? _userTicks
        : _userTicks
            .where((tick) => tick.createdAt.isAfter(startDate))
            .toList();

    final likes = startDate == null
        ? _userLikes
        : _userLikes
            .where((like) => like.createdAt.isAfter(startDate))
            .toList();

    final projects = startDate == null
        ? _userProjects
        : _userProjects
            .where((project) => project.createdAt.isAfter(startDate))
            .toList();

    final leadSends = ticks.where((tick) => tick.leadSend).toList();
    final inProgressRoutes = ticks
        .where((tick) =>
            (tick.topRopeAttempts > 0 ||
                tick.leadAttempts > 0 ||
                tick.topRopeSend) &&
            !tick.leadSend)
        .toList();

    final gradeTicksMap = <String, List<UserTick>>{};
    for (final tick in ticks) {
      gradeTicksMap.putIfAbsent(tick.routeGrade, () => <UserTick>[]).add(tick);
    }

    final gradeStats = gradeTicksMap.entries
        .map((entry) => GradeStatistics(grade: entry.key, ticks: entry.value))
        .toList()
      ..sort((a, b) => _gradeOrder(a.grade).compareTo(_gradeOrder(b.grade)));

    String? hardestGrade;
    bool hasHardestGrade = false;
    double? hardestOrder;
    for (final tick in ticks) {
      final order = _gradeOrder(tick.routeGrade);
      if (hardestOrder == null || order > hardestOrder) {
        hardestOrder = order;
        hardestGrade = tick.routeGrade;
        hasHardestGrade = true;
      }
    }

    _cachedFilter = _timeFilter;
    _cachedFilteredTicks = ticks;
    _cachedFilteredLikes = likes;
    _cachedFilteredProjects = projects;
    _cachedFilteredLeadSends = leadSends;
    _cachedFilteredInProgressRoutes = inProgressRoutes;
    _cachedFilteredGradeStats = gradeStats;
    _cachedFilteredHardestGrade = hardestGrade;
    _hasCachedFilteredHardestGrade = hasHardestGrade;
  }
}
