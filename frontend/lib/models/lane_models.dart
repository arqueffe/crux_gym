class Lane {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  Lane({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory Lane.fromJson(Map<String, dynamic> json) {
    return Lane(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? 'Lane ${json['id']}', // Use ID as fallback
      isActive: json['is_active'] == 1 ||
          json['is_active'] == true, // Handle both boolean and int
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => name;
}
