class Route {
  final int id;
  final String name;
  final String grade;
  final String? gradeColor;
  final String routeSetter;
  final String wallSection;
  final int lane;
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
    this.gradeColor,
    required this.routeSetter,
    required this.wallSection,
    required this.lane,
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
      gradeColor: json['grade_color'],
      routeSetter: json['route_setter'],
      wallSection: json['wall_section'],
      lane: json['lane'],
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
      'lane': lane,
      'color': color,
      'description': description,
    };
  }

  // Calculate average proposed grade
  String? get averageProposedGrade {
    if (gradeProposals == null || gradeProposals!.isEmpty) {
      return null;
    }

    // Map grades to numeric values for averaging
    Map<String, int> gradeValues = {
      'V0': 0,
      'V1': 1,
      'V2': 2,
      'V3': 3,
      'V4': 4,
      'V5': 5,
      'V6': 6,
      'V7': 7,
      'V8': 8,
      'V9': 9,
      'V10': 10,
      'V11': 11,
      'V12': 12,
    };

    List<String> grades = [
      'V0',
      'V1',
      'V2',
      'V3',
      'V4',
      'V5',
      'V6',
      'V7',
      'V8',
      'V9',
      'V10',
      'V11',
      'V12'
    ];

    double total = 0;
    int count = 0;

    for (var proposal in gradeProposals!) {
      if (gradeValues.containsKey(proposal.proposedGrade)) {
        total += gradeValues[proposal.proposedGrade]!;
        count++;
      }
    }

    if (count == 0) return null;

    int averageIndex = (total / count).round();
    return grades[averageIndex.clamp(0, grades.length - 1)];
  }
}

class Like {
  final int id;
  final int userId;
  final String userName;
  final int routeId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.userId,
    required this.userName,
    required this.routeId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      userId: json['user_id'],
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
  final int userId;
  final String userName;
  final String content;
  final int routeId;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.routeId,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      content: json['content'],
      routeId: json['route_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

class GradeProposal {
  final int id;
  final int userId;
  final String userName;
  final String proposedGrade;
  final String? reasoning;
  final int routeId;
  final DateTime createdAt;

  GradeProposal({
    required this.id,
    required this.userId,
    required this.userName,
    required this.proposedGrade,
    this.reasoning,
    required this.routeId,
    required this.createdAt,
  });

  factory GradeProposal.fromJson(Map<String, dynamic> json) {
    return GradeProposal(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      proposedGrade: json['proposed_grade'],
      reasoning: json['reasoning'],
      routeId: json['route_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposed_grade': proposedGrade,
      'reasoning': reasoning,
    };
  }
}

class Warning {
  final int id;
  final int userId;
  final String userName;
  final String warningType;
  final String description;
  final int routeId;
  final String status;
  final DateTime createdAt;

  Warning({
    required this.id,
    required this.userId,
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
      userId: json['user_id'],
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
      'warning_type': warningType,
      'description': description,
    };
  }
}

class Tick {
  final int id;
  final int userId;
  final String userName;
  final int routeId;
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

  Tick({
    required this.id,
    required this.userId,
    required this.userName,
    required this.routeId,
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

  factory Tick.fromJson(Map<String, dynamic> json) {
    return Tick(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      routeId: json['route_id'],
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

  Map<String, dynamic> toJson() {
    return {
      'attempts': attempts,
      'top_rope_send': topRopeSend,
      'lead_send': leadSend,
      'top_rope_flash': topRopeFlash,
      'lead_flash': leadFlash,
      'flash': flash,
      'notes': notes,
    };
  }
}
