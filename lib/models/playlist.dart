
class Playlist {
  final String? id;
  final String ownerId;
  final String name;
  final String description;
  final String imageUrl;

  Playlist({
    this.id,
    required this.name,
    required this.ownerId,
    required this.description,
    required this.imageUrl,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String?,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

}
 
