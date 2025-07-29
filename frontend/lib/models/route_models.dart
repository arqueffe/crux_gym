class Route {
  final int id;
  final String name;
  final String grade;
  final String routeSetter;
  final String wallSection;
  final String? color;
  final String? description;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int gradeProposalsCount;
  final int warningsCount;
  final int ticksCount;
  final List<Like>? likes;
  final List<Comment>? comments;
  final List<GradeProposal>? gradeProposals;
  final List<Warning>? warnings;
  final List<Tick>? ticks;

  Route({
    required this.id,
    required this.name,
    required this.grade,
    required this.routeSetter,
    required this.wallSection,
    this.color,
    this.description,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.gradeProposalsCount,
    required this.warningsCount,
    required this.ticksCount,
    this.likes,
    this.comments,
    this.gradeProposals,
    this.warnings,
    this.ticks,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      routeSetter: json['route_setter'],
      wallSection: json['wall_section'],
      color: json['color'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      gradeProposalsCount: json['grade_proposals_count'],
      warningsCount: json['warnings_count'],
      ticksCount: json['ticks_count'] ?? 0,
      likes: json['likes'] != null
          ? (json['likes'] as List).map((e) => Like.fromJson(e)).toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((e) => Comment.fromJson(e)).toList()
          : null,
      gradeProposals: json['grade_proposals'] != null
          ? (json['grade_proposals'] as List)
              .map((e) => GradeProposal.fromJson(e))
              .toList()
          : null,
      warnings: json['warnings'] != null
          ? (json['warnings'] as List).map((e) => Warning.fromJson(e)).toList()
          : null,
      ticks: json['ticks'] != null
          ? (json['ticks'] as List).map((e) => Tick.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
      'route_setter': routeSetter,
      'wall_section': wallSection,
      'color': color,
      'description': description,
    };
  }
}

class Like {
  final int id;
  final String userName;
  final int routeId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.userName,
    required this.routeId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      userName: json['user_name'],
      routeId: json['route_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
    };
  }
}

class Comment {
  final int id;
  final String userName;
  final String content;
  final int routeId;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.routeId,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userName: json['user_name'],
      content: json['content'],
      routeId: json['route_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'content': content,
    };
  }
}

class GradeProposal {
  final int id;
  final String userName;
  final String proposedGrade;
  final String? reasoning;
  final int routeId;
  final DateTime createdAt;

  GradeProposal({
    required this.id,
    required this.userName,
    required this.proposedGrade,
    this.reasoning,
    required this.routeId,
    required this.createdAt,
  });

  factory GradeProposal.fromJson(Map<String, dynamic> json) {
    return GradeProposal(
      id: json['id'],
      userName: json['user_name'],
      proposedGrade: json['proposed_grade'],
      reasoning: json['reasoning'],
      routeId: json['route_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'proposed_grade': proposedGrade,
      'reasoning': reasoning,
    };
  }
}

class Warning {
  final int id;
  final String userName;
  final String warningType;
  final String description;
  final int routeId;
  final String status;
  final DateTime createdAt;

  Warning({
    required this.id,
    required this.userName,
    required this.warningType,
    required this.description,
    required this.routeId,
    required this.status,
    required this.createdAt,
  });

  factory Warning.fromJson(Map<String, dynamic> json) {
    return Warning(
      id: json['id'],
      userName: json['user_name'],
      warningType: json['warning_type'],
      description: json['description'],
      routeId: json['route_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'warning_type': warningType,
      'description': description,
    };
  }
}

class Tick {
  final int id;
  final String userName;
  final int routeId;
  final int attempts;
  final bool flash;
  final String? notes;
  final DateTime createdAt;

  Tick({
    required this.id,
    required this.userName,
    required this.routeId,
    required this.attempts,
    required this.flash,
    this.notes,
    required this.createdAt,
  });

  factory Tick.fromJson(Map<String, dynamic> json) {
    return Tick(
      id: json['id'],
      userName: json['user_name'],
      routeId: json['route_id'],
      attempts: json['attempts'],
      flash: json['flash'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'attempts': attempts,
      'flash': flash,
      'notes': notes,
    };
  }
}
