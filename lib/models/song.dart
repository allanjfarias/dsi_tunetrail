class Song {
  final String songId;
  final String name;
  final String artist;
  final String album;
  final String coverUrl;
  final double duration;
  final String genre;
  final int popularity;
  final bool explicit;

  Song({
    required this.songId,
    required this.name,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.duration,
    required this.genre,
    required this.popularity,
    required this.explicit,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['id'] as String,
      name: json['track_name'] as String,
      artist: json['artists'] as String,
      album: json['album_name'] as String,
      coverUrl: json['cover_id'] as String,
      duration: (json['duration_ms'] as num).toDouble(),
      genre: json['track_genre'] as String,
      popularity: json['popularity'] as int,
      explicit: json['explicit'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': songId,
      'track_name': name,
      'artists': artist,
      'album_name': album,
      'cover_id': coverUrl,
      'duration_ms': duration,
      'track_genre': genre,
      'popularity': popularity,
      'explicit': explicit,
    };
  }
}
