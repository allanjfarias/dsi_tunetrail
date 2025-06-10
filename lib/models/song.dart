class Song {
  final String songId;
  final String name;
  final String artist;
  final String album;
  final String coverUrl;
  final double duration;
  final String genre;
  final int popularity;

  Song({
    required this.songId,
    required this.name,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.duration,
    required this.genre,
    required this.popularity,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['song_id'] as String,
      name: json['name'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      coverUrl: json['cover_url'] as String,
      duration: (json['duration'] as num).toDouble(),
      genre: json['genre'] as String,
      popularity: json['popularity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'song_id': songId,
      'name': name,
      'artist': artist,
      'album': album,
      'cover_url': coverUrl,
      'duration': duration,
      'genre': genre,
      'popularity': popularity,
    };
  }
}
