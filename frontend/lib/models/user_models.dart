class User {
  final int id;
  final String username; // private login identifier
  final String nickname; // public display name
  final String email;
  final DateTime createdAt;
  final bool isActive;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.email,
    required this.createdAt,
    required this.isActive,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'] ?? json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'role': role,
    };
  }

  // Role-based permission methods
  bool get isAdmin => role == 'admin';
  bool get isRouteSetter => role == 'route_setter';
  bool get canCreateRoutes => isAdmin || isRouteSetter;

  @override
  String toString() {
    return 'User{id: $id, username: $username, nickname: $nickname, email: $email}';
  }
}
