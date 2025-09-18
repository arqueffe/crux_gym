/// Role model for the climbing gym role system
class Role {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final List<String> capabilities;
  final bool isActive;
  final DateTime createdAt;

  Role({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.capabilities,
    required this.isActive,
    required this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: int.parse(json['id']),
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      capabilities: List<String>.from(json['capabilities'] ?? []),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'capabilities': capabilities,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Check if this role has a specific capability
  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }

  /// Get a display-friendly description of the role
  String get displayDescription {
    return description ?? 'No description available';
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, slug: $slug, capabilities: ${capabilities.length})';
  }
}

/// User role assignment model
class UserRole extends Role {
  final DateTime assignedAt;
  final bool userRoleActive;

  UserRole({
    required int id,
    required String name,
    required String slug,
    String? description,
    required List<String> capabilities,
    required bool isActive,
    required DateTime createdAt,
    required this.assignedAt,
    required this.userRoleActive,
  }) : super(
          id: id,
          name: name,
          slug: slug,
          description: description,
          capabilities: capabilities,
          isActive: isActive,
          createdAt: createdAt,
        );

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      capabilities: List<String>.from(json['capabilities'] ?? []),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at']),
      assignedAt: DateTime.parse(json['assigned_at']),
      userRoleActive:
          json['user_role_active'] == 1 || json['user_role_active'] == true,
    );
  }

  @override
  String toString() {
    return 'UserRole(id: $id, name: $name, assigned: $assignedAt)';
  }
}

/// Available capabilities in the system
class Capability {
  static const String manageSystem = 'manage_system';
  static const String manageUsers = 'manage_users';
  static const String manageRoles = 'manage_roles';
  static const String createRoutes = 'create_routes';
  static const String editRoutes = 'edit_routes';
  static const String editOwnRoutes = 'edit_own_routes';
  static const String deleteRoutes = 'delete_routes';
  static const String manageGrades = 'manage_grades';
  static const String manageHoldColors = 'manage_hold_colors';
  static const String manageLanes = 'manage_lanes';
  static const String viewAnalytics = 'view_analytics';
  static const String manageWarnings = 'manage_warnings';
  static const String moderateComments = 'moderate_comments';
  static const String viewRoutes = 'view_routes';
  static const String likeRoutes = 'like_routes';
  static const String commentRoutes = 'comment_routes';
  static const String trackProgress = 'track_progress';
  static const String proposeGrades = 'propose_grades';
  static const String addProjects = 'add_projects';
  static const String reportWarnings = 'report_warnings';

  /// Get all available capabilities
  static List<String> getAllCapabilities() {
    return [
      manageSystem,
      manageUsers,
      manageRoles,
      createRoutes,
      editRoutes,
      editOwnRoutes,
      deleteRoutes,
      manageGrades,
      manageHoldColors,
      manageLanes,
      viewAnalytics,
      manageWarnings,
      moderateComments,
      viewRoutes,
      likeRoutes,
      commentRoutes,
      trackProgress,
      proposeGrades,
      addProjects,
      reportWarnings,
    ];
  }

  /// Get capability display names
  static Map<String, String> getCapabilityDisplayNames() {
    return {
      manageSystem: 'Manage System',
      manageUsers: 'Manage Users',
      manageRoles: 'Manage Roles',
      createRoutes: 'Create Routes',
      editRoutes: 'Edit All Routes',
      editOwnRoutes: 'Edit Own Routes',
      deleteRoutes: 'Delete Routes',
      manageGrades: 'Manage Grades',
      manageHoldColors: 'Manage Hold Colors',
      manageLanes: 'Manage Lanes',
      viewAnalytics: 'View Analytics',
      manageWarnings: 'Manage Warnings',
      moderateComments: 'Moderate Comments',
      viewRoutes: 'View Routes',
      likeRoutes: 'Like Routes',
      commentRoutes: 'Comment on Routes',
      trackProgress: 'Track Progress',
      proposeGrades: 'Propose Grades',
      addProjects: 'Add Projects',
      reportWarnings: 'Report Warnings',
    };
  }

  /// Get capability descriptions
  static Map<String, String> getCapabilityDescriptions() {
    return {
      manageSystem:
          'Full system administration including all settings and configurations',
      manageUsers: 'Add, edit, and remove user accounts and assign roles',
      manageRoles: 'Create, edit, and delete user roles and permissions',
      createRoutes: 'Create new climbing routes in the system',
      editRoutes: 'Edit any route in the system',
      editOwnRoutes: 'Edit only routes created by the user',
      deleteRoutes: 'Delete routes from the system',
      manageGrades: 'Manage climbing grade definitions and colors',
      manageHoldColors: 'Manage hold color definitions',
      manageLanes: 'Manage climbing wall lane configurations',
      viewAnalytics: 'Access to system analytics and reports',
      manageWarnings: 'Handle and resolve route warnings',
      moderateComments: 'Moderate user comments on routes',
      viewRoutes: 'View climbing routes and their details',
      likeRoutes: 'Like and unlike climbing routes',
      commentRoutes: 'Add comments to climbing routes',
      trackProgress: 'Track climbing progress and attempts',
      proposeGrades: 'Propose grade changes for routes',
      addProjects: 'Add routes to personal project list',
      reportWarnings: 'Report safety warnings on routes',
    };
  }

  /// Get a user-friendly name for a capability
  static String getDisplayName(String capability) {
    return getCapabilityDisplayNames()[capability] ?? capability;
  }

  /// Get a description for a capability
  static String getDescription(String capability) {
    return getCapabilityDescriptions()[capability] ??
        'No description available';
  }
}
