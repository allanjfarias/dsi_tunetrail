class Playlist {
  final String? id;
  final String title;
  final String ownerId;
  final String? ownerFullName;
  final String? ownerAvatarUrl;
  final String? coverUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Playlist({
    this.id,
    required this.title,
    required this.ownerId,
    this.ownerFullName,
    this.ownerAvatarUrl,
    this.coverUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'] as String?,
    title: json['title'] as String,
    ownerId: json['owner_id'] as String,
    ownerFullName: json['owner_name'] as String?,
    ownerAvatarUrl: json['owner_avatar_url'] as String?,
    coverUrl: json['cover_url'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    'title': title,
    'owner_id': ownerId,
    if (ownerFullName != null) 'owner_name': ownerFullName,
    if (ownerAvatarUrl != null) 'owner_avatar_url': ownerAvatarUrl,
    if (coverUrl != null) 'cover_url': coverUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  Playlist copyWith({
    String? id,
    String? title,
    String? ownerId,
    String? ownerFullName,
    String? ownerAvatarUrl,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  String toString() {
    return 'Playlist{id: $id, title: $title, ownerId: $ownerId, ownerFullName: $ownerFullName, coverUrl: $coverUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          ownerId == other.ownerId &&
          coverUrl == other.coverUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      ownerId.hashCode ^
      coverUrl.hashCode;
}