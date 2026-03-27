int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String _parseString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final str = value.toString();
  if (str == 'null') return fallback;
  return str;
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  if (str.isEmpty || str == 'null') return null;
  return str;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == '1' || normalized == 'true';
}

DateTime _parseDateTime(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty || raw.startsWith('0000-00-00')) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.tryParse(raw) ??
      DateTime.tryParse(raw.replaceFirst(' ', 'T')) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class Route {
  final int id;
  final String name;
  final int gradeId;
  final String? gradeName;
  final String? gradeColor;
  final String? image;
  final String routeSetter;
  final String wallSection;
  final int lane;
  final String? laneName;
  final int holdColorId;
  final String? colorName;
  final String? colorHex;
  final String? description;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int gradeProposalsCount;
  final int warningsCount;
  // Backend now returns send count (top-rope or lead), not raw tick-row count.
  final int ticksCount;
  final int projectsCount;
  final List<Like>? likes;
  final List<Comment>? comments;
  final List<GradeProposal>? gradeProposals;
  final List<Warning>? warnings;
  final List<Tick>? ticks;
  final List<NameProposal>? nameProposals;

  Route({
    required this.id,
    required this.name,
    required this.gradeId,
    this.gradeName,
    this.gradeColor,
    this.image,
    required this.routeSetter,
    required this.wallSection,
    required this.lane,
    this.laneName,
    required this.holdColorId,
    this.colorName,
    this.colorHex,
    this.description,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.gradeProposalsCount,
    required this.warningsCount,
    required this.ticksCount,
    required this.projectsCount,
    this.likes,
    this.comments,
    this.gradeProposals,
    this.warnings,
    this.ticks,
    this.nameProposals,
  });

  String displayName({required String unnamedFallback}) {
    if (name != 'Unnamed') {
      return name;
    }

    final proposals = nameProposals;
    if (proposals == null || proposals.isEmpty) {
      return unnamedFallback;
    }

    final sorted = List<NameProposal>.from(proposals)
      ..sort((a, b) {
        final voteComparison = b.voteCount.compareTo(a.voteCount);
        if (voteComparison != 0) {
          return voteComparison;
        }
        return a.createdAt.compareTo(b.createdAt);
      });

    final topProposal = sorted.first.proposedName.trim();
    return topProposal.isEmpty ? unnamedFallback : topProposal;
  }

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], fallback: 'Unnamed'),
      gradeId: _parseInt(json['grade_id']),
      gradeName: null, // Will be populated by frontend mapping
      gradeColor: null, // Will be populated by frontend mapping
      image: _parseNullableString(json['image']),
      routeSetter: _parseString(json['route_setter']),
      wallSection: _parseString(json['wall_section']),
      lane: _parseInt(json['lane_id']),
      laneName: _parseNullableString(json['lane_name']),
      holdColorId: _parseInt(json['hold_color_id']),
      colorName: null, // Will be populated by frontend mapping
      colorHex: null, // Will be populated by frontend mapping
      description: _parseNullableString(json['description']),
      createdAt: _parseDateTime(json['created_at']),
      likesCount: _parseInt(json['likes_count']),
      commentsCount: _parseInt(json['comments_count']),
      gradeProposalsCount: _parseInt(json['grade_proposals_count']),
      warningsCount: _parseInt(json['warnings_count']),
      ticksCount: _parseInt(json['ticks_count']),
      projectsCount: _parseInt(json['projects_count']),
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
      nameProposals: json['name_proposals'] != null
          ? (json['name_proposals'] as List)
              .map((e) => NameProposal.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'name': name,
      'grade_id': gradeId,
      'route_setter': routeSetter,
      'image': image,
      'wall_section': wallSection,
      'lane_id': lane,
    };

    result['hold_color_id'] = holdColorId;
    if (description != null) {
      result['description'] = description!;
    }

    return result;
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
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      routeId: _parseInt(json['route_id']),
      createdAt: _parseDateTime(json['created_at']),
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
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      content: _parseString(json['content']),
      routeId: _parseInt(json['route_id']),
      createdAt: _parseDateTime(json['created_at']),
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
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      proposedGrade: _parseString(json['proposed_grade']),
      reasoning: _parseNullableString(json['reasoning']),
      routeId: _parseInt(json['route_id']),
      createdAt: _parseDateTime(json['created_at']),
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
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      warningType: _parseString(json['warning_type']),
      description: _parseString(json['description']),
      routeId: _parseInt(json['route_id']),
      status: _parseString(json['status']),
      createdAt: _parseDateTime(json['created_at']),
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
  final int topRopeAttempts;
  final int leadAttempts;
  final bool topRopeSend;
  final bool leadSend;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tick({
    required this.id,
    required this.userId,
    required this.userName,
    required this.routeId,
    required this.topRopeAttempts,
    required this.leadAttempts,
    required this.topRopeSend,
    required this.leadSend,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tick.fromJson(Map<String, dynamic> json) {
    return Tick(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      routeId: _parseInt(json['route_id']),
      topRopeAttempts: _parseInt(json['top_rope_attempts']),
      leadAttempts: _parseInt(json['lead_attempts']),
      topRopeSend: _parseBool(json['top_rope_send']),
      leadSend: _parseBool(json['lead_send']),
      notes: _parseNullableString(json['notes']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_rope_attempts': topRopeAttempts,
      'lead_attempts': leadAttempts,
      'top_rope_send': topRopeSend,
      'lead_send': leadSend,
      'notes': notes,
    };
  }
}

class Project {
  final int id;
  final int userId;
  final String userName;
  final int routeId;
  final String? routeName;
  final String? routeGrade;
  final String? routeWallSection;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.userId,
    required this.userName,
    required this.routeId,
    this.routeName,
    this.routeGrade,
    this.routeWallSection,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      routeId: _parseInt(json['route_id']),
      routeName: _parseNullableString(json['route_name']),
      routeGrade: _parseNullableString(json['route_grade']),
      routeWallSection: _parseNullableString(json['route_wall_section']),
      notes: _parseNullableString(json['notes']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes': notes,
    };
  }
}

class NameProposal {
  final int id;
  final String proposedName;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final int voteCount;

  NameProposal({
    required this.id,
    required this.proposedName,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.voteCount,
  });

  factory NameProposal.fromJson(Map<String, dynamic> json) {
    return NameProposal(
      id: _parseInt(json['id']),
      proposedName: _parseString(json['proposed_name']),
      userId: _parseInt(json['user_id']),
      userName: _parseString(json['user_name']),
      createdAt: _parseDateTime(json['created_at']),
      voteCount: _parseInt(json['vote_count']),
    );
  }
}
