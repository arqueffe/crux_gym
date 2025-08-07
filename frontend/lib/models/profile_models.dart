class UserTick {
  final int id;
  final int userId;
  final int routeId;
  final String routeName;
  final String routeGrade;
  final String wallSection;
  final int attempts;
  final bool topRopeSend;
  final bool leadSend;
  final bool topRopeFlash;
  final bool leadFlash;
  final bool flash; // Legacy field for backward compatibility
  final bool hasAnySend;
  final bool hasAnyFlash;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserTick({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.routeName,
    required this.routeGrade,
    required this.wallSection,
    required this.attempts,
    required this.topRopeSend,
    required this.leadSend,
    required this.topRopeFlash,
    required this.leadFlash,
    required this.flash,
    required this.hasAnySend,
    required this.hasAnyFlash,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserTick.fromJson(Map<String, dynamic> json) {
    return UserTick(
      id: json['id'],
      userId: json['user_id'],
      routeId: json['route_id'],
      routeName: json['route_name'],
      routeGrade: json['route_grade'],
      wallSection: json['wall_section'],
      attempts: json['attempts'] ?? 0,
      topRopeSend: json['top_rope_send'] ?? false,
      leadSend: json['lead_send'] ?? false,
      topRopeFlash: json['top_rope_flash'] ?? false,
      leadFlash: json['lead_flash'] ?? false,
      flash: json['flash'] ?? false,
      hasAnySend: json['has_any_send'] ?? false,
      hasAnyFlash: json['has_any_flash'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
  final int totalAttempts;
  final double averageAttempts;

  // Send statistics
  final int totalSends;
  final int topRopeSends;
  final int leadSends;

  // Flash statistics
  final int totalFlashes;
  final int topRopeFlashes;
  final int leadFlashes;
  final int legacyFlashes; // For backward compatibility

  // Grade achievements
  final String? hardestGrade;
  final String? hardestTopRopeGrade;
  final String? hardestLeadGrade;
  final int uniqueWallSections;
  final List<String> achievedGrades;

  ProfileStats({
    required this.totalTicks,
    required this.totalLikes,
    required this.totalComments,
    required this.totalAttempts,
    required this.averageAttempts,
    required this.totalSends,
    required this.topRopeSends,
    required this.leadSends,
    required this.totalFlashes,
    required this.topRopeFlashes,
    required this.leadFlashes,
    required this.legacyFlashes,
    this.hardestGrade,
    this.hardestTopRopeGrade,
    this.hardestLeadGrade,
    required this.uniqueWallSections,
    required this.achievedGrades,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalTicks: json['total_ticks'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      averageAttempts: (json['average_attempts'] as num?)?.toDouble() ?? 0.0,
      totalSends: json['total_sends'] ?? 0,
      topRopeSends: json['top_rope_sends'] ?? 0,
      leadSends: json['lead_sends'] ?? 0,
      totalFlashes: json['total_flashes'] ?? 0,
      topRopeFlashes: json['top_rope_flashes'] ?? 0,
      leadFlashes: json['lead_flashes'] ?? 0,
      legacyFlashes: json['legacy_flashes'] ?? 0,
      hardestGrade: json['hardest_grade'],
      hardestTopRopeGrade: json['hardest_top_rope_grade'],
      hardestLeadGrade: json['hardest_lead_grade'],
      uniqueWallSections: json['unique_wall_sections'] ?? 0,
      achievedGrades: List<String>.from(json['achieved_grades'] ?? []),
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
