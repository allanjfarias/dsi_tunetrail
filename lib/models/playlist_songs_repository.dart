import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

class PlaylistSongRepository {
  final SupabaseClient supabase;

  PlaylistSongRepository({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<void> linkSongToPlaylist(String playlistId, String songId) async {
    try {
      await supabase.from('playlist_songs').insert(<String, String>{
        'playlist_id': playlistId,
        'song_id': songId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkSongFromPlaylist(String playlistId, String songId) async {
    try {
      await supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Song>> fetchSongsFromPlaylist(String playlistId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('playlist_songs')
          .select('song:song_id(*)')
          .eq('playlist_id', playlistId);


      final List<Song> songs = (response as List<dynamic>)
          .map((dynamic e) => Song.fromJson(e['song'] as Map<String, dynamic>))
          .toList();

      return songs;
    } catch (e) {
      rethrow;
    }
  }
}
