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
    final rawDate = json['created_at']?.toString().trim();
    final parsedDate =
        (rawDate == null || rawDate.isEmpty || rawDate.startsWith('0000-00-00'))
            ? DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.tryParse(rawDate) ??
                DateTime.tryParse(rawDate.replaceFirst(' ', 'T')) ??
                DateTime.fromMillisecondsSinceEpoch(0);

    return Lane(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name']?.toString().isNotEmpty ?? false)
          ? json['name'].toString()
          : 'Lane ${json['id']}',
      createdAt: parsedDate,
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
