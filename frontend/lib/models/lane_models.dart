class Lane {
  final int id;
  final String name;
  final DateTime createdAt;

  Lane({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Lane.fromJson(Map<String, dynamic> json) {
    return Lane(
      id: int.parse(json['id']),
      name: json['name'] ?? 'Lane ${json['id']}',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => name;
}
