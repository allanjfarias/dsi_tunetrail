import '/models/playlist_songs_repository.dart';
import '/models/crud_repository.dart';
import '/models/playlist.dart';
import '/models/song.dart';


class PlaylistController {
  final CrudRepository<Playlist> _playlistRepo;
  final PlaylistSongRepository _playlistSongRepo;
  final String currentUserId;

  PlaylistController({
    required CrudRepository<Playlist> playlistRepo,
    required PlaylistSongRepository playlistSongRepo,
    required this.currentUserId,
  }) : _playlistSongRepo = playlistSongRepo, _playlistRepo = playlistRepo;

  Future<Playlist> createPlaylist({
    required String name,
  }) {
    final Playlist playlist = Playlist(
      id: null,
      ownerId: currentUserId,
      name: name
    );

    return _playlistRepo.create(playlist);
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _playlistRepo.delete(playlistId);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) {
    return _playlistSongRepo.linkSongToPlaylist(playlistId, songId);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) {
    return _playlistSongRepo.unlinkSongFromPlaylist(playlistId, songId);
  }

  Future<List<Song>> fetchSongsFromPlaylist(String playlistId) {
    return _playlistSongRepo.fetchSongsFromPlaylist(playlistId);
  }

  Future<List<Playlist>> getMyPlaylists() async {
    final List<Playlist> all = await _playlistRepo.readAll();
    return all.where( (Playlist p) => p.ownerId == currentUserId).toList();
  }
}
