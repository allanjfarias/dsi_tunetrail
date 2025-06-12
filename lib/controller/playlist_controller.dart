import '../models/playlist_songs_link.dart';
import '../models/playlist_repository.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistController {
  final PlaylistRepository playlistRepository;
  final PlaylistSongRepository _playlistSongRepo;
  final String currentUserId;

  PlaylistController({
    required this.playlistRepository,
    required PlaylistSongRepository playlistSongRepo,
    required this.currentUserId,
  }) : _playlistSongRepo = playlistSongRepo;

  Future<Playlist> createPlaylist({required String name}) {
    final Playlist playlist = Playlist(
      ownerId: currentUserId,
      name: name,
    );

    return playlistRepository.create(playlist);
  }

  Future<void> deletePlaylist(String playlistId) async {
    await playlistRepository.delete(playlistId);
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
    final List<Playlist> all = await playlistRepository.readAll();
    return all.where((Playlist p) => p.ownerId == currentUserId).toList();
  }
}
