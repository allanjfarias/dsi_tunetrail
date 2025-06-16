class Tag {
  final String? id;
  final String? userId;
  final String name;
  final String? creatorName;

  Tag({
    this.id,
    this.userId,
    required this.name,
    this.creatorName,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      creatorName: json['creator_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
    };
  }

  String get generatedColor {
    final int hash = name.codeUnits.fold(
      0,
      (int prev, int curr) => curr + ((prev << 5) - prev),
    );
    final int hue = hash % 360;
    return 'hsl($hue, 70%, 70%)';
  }

  Tag copyWith({
    String? id,
    String? userId,
    String? name,
    String? creatorName,
  }) {
    return Tag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      creatorName: creatorName ?? this.creatorName,
    );
  }
}