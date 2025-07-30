import 'package:flutter/foundation.dart';
import '../models/profile_models.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  late final ApiService _apiService;

  ProfileProvider({required AuthProvider authProvider}) {
    _apiService = ApiService(authProvider: authProvider);
  }

  List<UserTick> _userTicks = [];
  List<UserLike> _userLikes = [];
  List<GradeStatistics> _gradeStats = [];
  ProfileStats? _profileStats;
  bool _isLoading = false;
  String? _error;
  ProfileTimeFilter _timeFilter = ProfileTimeFilter.all;

  // Getters
  List<UserTick> get userTicks => _userTicks;
  List<UserLike> get userLikes => _userLikes;
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
      final totalAttempts =
          ticks.fold<int>(0, (sum, tick) => sum + tick.attempts);
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
    // Simple V-scale ordering
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

  Future<void> loadProfile() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _loadUserTicks(),
        _loadUserLikes(),
        _loadProfileStats(),
      ]);

      _calculateGradeStats();
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserTicks() async {
    try {
      final response = await _apiService.get('/user/ticks');
      if (response['success']) {
        _userTicks = (response['data'] as List)
            .map((json) => UserTick.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw 'Failed to load user ticks: $e';
    }
  }

  Future<void> _loadUserLikes() async {
    try {
      final response = await _apiService.get('/user/likes');
      if (response['success']) {
        _userLikes = (response['data'] as List)
            .map((json) => UserLike.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw 'Failed to load user likes: $e';
    }
  }

  Future<void> _loadProfileStats() async {
    try {
      final response = await _apiService.get('/user/stats');
      if (response['success']) {
        _profileStats = ProfileStats.fromJson(response['data']);
      }
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
      final totalAttempts =
          ticks.fold<int>(0, (sum, tick) => sum + tick.attempts);
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}
