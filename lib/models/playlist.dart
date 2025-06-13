class Playlist {
  final String? id;
  final String ownerId;
  final String title;

  Playlist({this.id, required this.title, required this.ownerId});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String?,
      ownerId: json['owner_id'] as String,
      title: json["title"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{
      'owner_id': ownerId,
      'title': title,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
