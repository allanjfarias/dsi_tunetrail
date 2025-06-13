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
    final String fullCoverUrl = (json['covers'] as Map<String, dynamic>?)?['image_url'] as String? ?? '';

    return Song(
      songId: json['id'] as String,
      name: json['track_name'] as String,
      artist: json['artists'] as String,
      album: json['album_name'] as String,
      coverUrl: fullCoverUrl,
      duration: (json['duration_ms'] as num?)?.toDouble() ?? 0.0,
      genre: json['track_genre'] as String,
      popularity: json['popularity'] as int? ?? 0,
      explicit: json['explicit'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': songId,
      'track_name': name,
      'artists': artist,
      'album_name': album,
      'duration_ms': duration,
      'track_genre': genre,
      'popularity': popularity,
      'explicit': explicit,
    };
  }
}
