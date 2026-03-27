class UserTick {
  final int id;
  final int userId;
  final int routeId;
  final int topRopeAttempts;
  final int leadAttempts;
  final bool topRopeSend;
  final bool leadSend;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String routeName;
  final String routeGrade;
  final String wallSection;

  UserTick({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.topRopeAttempts,
    required this.leadAttempts,
    required this.topRopeSend,
    required this.leadSend,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.routeName,
    required this.routeGrade,
    required this.wallSection,
  });

  factory UserTick.fromJson(Map<String, dynamic> json) {
    return UserTick(
      id: int.parse(json['id']),
      userId: int.parse(json['user_id']),
      routeId: int.parse(json['route_id']),
      topRopeAttempts: int.parse(json['top_rope_attempts']),
      leadAttempts: int.parse(json['lead_attempts']),
      topRopeSend: int.parse(json['top_rope_send']) == 1,
      leadSend: int.parse(json['lead_send']) == 1,
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      routeName: json['route_name'] ?? '',
      routeGrade: json['route_grade'] ?? '',
      wallSection: json['wall_section'] ?? '',
    );
  }

  // Flash is lead-only by product definition.
  bool get isTopRopeFlash => false;

  bool get isLeadFlash => leadSend && leadAttempts == 1 && topRopeAttempts == 0;

  int get attempts => topRopeAttempts + leadAttempts;
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
      id: int.parse(json['id']),
      userId: int.parse(json['user_id']),
      routeId: int.parse(json['route_id']),
      routeName: json['route_name'],
      routeGrade: json['route_grade'],
      wallSection: json['wall_section'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class GradeStatistics {
  final String grade;
  final int topRopeSends;
  final int leadSends;
  final int leadAttemptedRoutes;
  final int topRopeAttempts;
  final int leadAttempts;
  final int leadAttemptsOnLeadSends;
  final int flashCount;

  GradeStatistics({
    required this.grade,
    required List<UserTick> ticks,
  })  : topRopeSends = ticks
            .where((tick) => tick.topRopeSend && tick.routeGrade == grade)
            .length,
        leadSends = ticks
            .where((tick) => tick.leadSend && tick.routeGrade == grade)
            .length,
        leadAttemptedRoutes = ticks
            .where((tick) =>
                tick.routeGrade == grade &&
                (tick.leadAttempts > 0 || tick.leadSend))
            .length,
        topRopeAttempts = ticks
            .where((tick) => tick.routeGrade == grade)
            .fold(0, (sum, tick) => sum + tick.topRopeAttempts),
        leadAttempts = ticks
            .where((tick) => tick.routeGrade == grade)
            .fold(0, (sum, tick) => sum + tick.leadAttempts),
        leadAttemptsOnLeadSends = ticks
            .where((tick) => tick.routeGrade == grade && tick.leadSend)
            .fold(0, (sum, tick) => sum + tick.leadAttempts),
        flashCount = ticks
            .where((tick) => tick.routeGrade == grade && tick.isLeadFlash)
            .length;

  double get averageAttempts {
    return leadSends > 0 ? leadAttemptsOnLeadSends / leadSends : 0.0;
  }

  // Ratio requested by product: first-attempt lead sends / lead attempted routes.
  double? get flashRate {
    return leadAttemptedRoutes > 0 ? flashCount / leadAttemptedRoutes : null;
  }

  double get flashShareOnLeadAttempts {
    return flashRate ?? 0.0;
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

class ProfileStats {
  final int totalLikes;
  final int totalComments;
  final int totalProjects;

  // Attempts statistics
  final int topRopeAttempts;
  final int leadAttempts;

  // Send statistics
  final int topRopeSends;
  final int leadSends;

  // Flash statistics
  final int topRopeFlashes;
  final int leadFlashes;

  // Grade achievements
  final String? hardestGrade;
  final String? hardestTopRopeGrade;
  final String? hardestLeadGrade;
  final List<String> achievedGrades;

  ProfileStats({
    required this.totalLikes,
    required this.totalComments,
    required this.totalProjects,
    required this.topRopeAttempts,
    required this.leadAttempts,
    required this.topRopeSends,
    required this.leadSends,
    required this.topRopeFlashes,
    required this.leadFlashes,
    required this.hardestGrade,
    required this.hardestTopRopeGrade,
    required this.hardestLeadGrade,
    required this.achievedGrades,
  });

  int get totalAttempts => topRopeAttempts + leadAttempts;

  double get averageAttempts => leadSends > 0 ? totalAttempts / leadSends : 0.0;
}

class UserProject {
  final int id;
  final int userId;
  final int routeId;
  final String routeName;
  final String routeGrade;
  final String wallSection;
  final DateTime createdAt;

  UserProject({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.routeName,
    required this.routeGrade,
    required this.wallSection,
    required this.createdAt,
  });

  factory UserProject.fromJson(Map<String, dynamic> json) {
    return UserProject(
      id: int.parse(json['id']),
      userId: int.parse(json['user_id']),
      routeId: int.parse(json['route_id']),
      routeName: json['route_name'],
      routeGrade: json['route_grade'],
      wallSection: json['route_wall_section'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
