class Lane {
  final int id;
  final int number;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  Lane({
    required this.id,
    required this.number,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory Lane.fromJson(Map<String, dynamic> json) {
    return Lane(
      id: json['id'],
      number: json['number'],
      name: json['name'] ??
          'Lane ${json['number']}', // Provide fallback if name is null
      isActive: json['is_active'] == 1 ||
          json['is_active'] == true, // Handle both boolean and int
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => name;
}
