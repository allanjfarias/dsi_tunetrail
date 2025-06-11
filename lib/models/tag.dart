class Tag {
  final String id;
  final String userId;
  final String name;

  Tag({required this.id, required this.userId, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'user_id': userId, 'name': name};
  }

  String get generatedColor {
    final int hash = name.codeUnits.fold(
      0,
      (int prev, int curr) => curr + ((prev << 5) - prev),
    );
    final int hue = hash % 360;
    return 'hsl($hue, 70%, 70%)';
  }
}
