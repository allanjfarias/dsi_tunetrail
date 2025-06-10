class Playlist {
  final String? id;
  final String ownerId;
  final String name;

  Playlist({
    this.id,
    required this.name,
    required this.ownerId,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String?,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{
      'owner_id': ownerId,
      'name': name,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

}
 
