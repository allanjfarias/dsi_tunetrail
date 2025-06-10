class Comment {
  final String id;
  final String content;
  final String userId;
  final String songId;

  Comment({
    required this.id,
    required this.content,
    required this.songId,
    required this.userId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    content: json['content'],
    songId: json['song_id'],
    userId: json['user_id'],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'content': content,
    'song_id': songId,
    'user_id': userId,
  };
}
