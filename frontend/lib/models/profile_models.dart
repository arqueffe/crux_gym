class UserTick {
  final int id;
  final int userId;
  final int routeId;
  final String routeName;
  final String routeGrade;
  final String wallSection;
  final int attempts;
  final bool flash;
  final String? notes;
  final DateTime createdAt;

  UserTick({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.routeName,
    required this.routeGrade,
    required this.wallSection,
    required this.attempts,
    required this.flash,
    this.notes,
    required this.createdAt,
  });

  factory UserTick.fromJson(Map<String, dynamic> json) {
    return UserTick(
      id: json['id'],
      userId: json['user_id'],
      routeId: json['route_id'],
      routeName: json['route_name'],
      routeGrade: json['route_grade'],
      wallSection: json['wall_section'],
      attempts: json['attempts'],
      flash: json['flash'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class UserLike {
  final int id;
  final int userId;
  final int routeId;
  final String routeName;
  final String routeGrade;
  final String wallSection;
  final DateTime createdAt;

  UserLike({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.routeName,
    required this.routeGrade,
    required this.wallSection,
    required this.createdAt,
  });

  factory UserLike.fromJson(Map<String, dynamic> json) {
    return UserLike(
      id: json['id'],
      userId: json['user_id'],
      routeId: json['route_id'],
      routeName: json['route_name'],
      routeGrade: json['route_grade'],
      wallSection: json['wall_section'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class GradeStatistics {
  final String grade;
  final int tickCount;
  final int totalAttempts;
  final int flashCount;
  final double averageAttempts;
  final double flashRate;

  GradeStatistics({
    required this.grade,
    required this.tickCount,
    required this.totalAttempts,
    required this.flashCount,
    required this.averageAttempts,
    required this.flashRate,
  });

  factory GradeStatistics.fromJson(Map<String, dynamic> json) {
    return GradeStatistics(
      grade: json['grade'],
      tickCount: json['tick_count'],
      totalAttempts: json['total_attempts'],
      flashCount: json['flash_count'],
      averageAttempts: (json['average_attempts'] as num).toDouble(),
      flashRate: (json['flash_rate'] as num).toDouble(),
    );
  }
}

class ProfileStats {
  final int totalTicks;
  final int totalLikes;
  final int totalComments;
  final int totalFlashes;
  final double averageAttempts;
  final String? hardestGrade;
  final int uniqueWallSections;
  final List<String> achievedGrades;

  ProfileStats({
    required this.totalTicks,
    required this.totalLikes,
    required this.totalComments,
    required this.totalFlashes,
    required this.averageAttempts,
    this.hardestGrade,
    required this.uniqueWallSections,
    required this.achievedGrades,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalTicks: json['total_ticks'],
      totalLikes: json['total_likes'],
      totalComments: json['total_comments'],
      totalFlashes: json['total_flashes'],
      averageAttempts: (json['average_attempts'] as num).toDouble(),
      hardestGrade: json['hardest_grade'],
      uniqueWallSections: json['unique_wall_sections'],
      achievedGrades: List<String>.from(json['achieved_grades']),
    );
  }
}

enum ProfileTimeFilter {
  all,
  lastWeek,
  lastMonth,
  last3Months,
  lastYear,
}

extension ProfileTimeFilterExtension on ProfileTimeFilter {
  String get displayName {
    switch (this) {
      case ProfileTimeFilter.all:
        return 'All Time';
      case ProfileTimeFilter.lastWeek:
        return 'Last Week';
      case ProfileTimeFilter.lastMonth:
        return 'Last Month';
      case ProfileTimeFilter.last3Months:
        return 'Last 3 Months';
      case ProfileTimeFilter.lastYear:
        return 'Last Year';
    }
  }

  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case ProfileTimeFilter.all:
        return null;
      case ProfileTimeFilter.lastWeek:
        return now.subtract(const Duration(days: 7));
      case ProfileTimeFilter.lastMonth:
        return now.subtract(const Duration(days: 30));
      case ProfileTimeFilter.last3Months:
        return now.subtract(const Duration(days: 90));
      case ProfileTimeFilter.lastYear:
        return now.subtract(const Duration(days: 365));
    }
  }
}
