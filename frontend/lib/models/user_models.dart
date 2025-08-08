class User {
  final int id;
  final String username; // private login identifier
  final String nickname; // public display name
  final String email;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.email,
    required this.createdAt,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'] ?? json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
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
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, nickname: $nickname, email: $email}';
  }
}
