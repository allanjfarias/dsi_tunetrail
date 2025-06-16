class Comment {
  final String? id;
  final String content;
  final String userId;
  final String songId;
  final String? userName;
  final String? userAvatarUrl;

  Comment({
    this.id,
    required this.content,
    required this.songId,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String?,
    content: json['content'] as String,
    songId: json['song_id'] as String,
    userId: json['user_id'] as String,
    userName: json['user_name'] as String?,
    userAvatarUrl: json['user_avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    'content': content,
    'song_id': songId,
    'user_id': userId,
  };

  Comment copyWith({
    String? id,
    String? content,
    String? userId,
    String? songId,
    String? userName,
    String? userAvatarUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      songId: songId ?? this.songId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
    );
  }
}