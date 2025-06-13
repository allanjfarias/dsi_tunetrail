import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

class PlaylistSongRepository {
  final SupabaseClient supabase;

  PlaylistSongRepository({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<void> linkSongToPlaylist(String playlistId, String songId, int position) async {
    try {
      await supabase.from('playlist_songs').insert(<String, dynamic>{
        'playlist_id': playlistId,
        'song_id': songId,
        'position': position,
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
          .eq('playlist_id', playlistId)
          .order('position', ascending: true);

      final List<Song> songs =
          (response as List<dynamic>)
              .map(
                (dynamic e) => Song.fromJson(e['song'] as Map<String, dynamic>),
              )
              .toList();

      return songs;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSongPosition(String playlistId, String songId, int newPosition) async {
    try {
      await supabase
          .from('playlist_songs')
          .update({'position': newPosition})
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getNextPosition(String playlistId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('playlist_songs')
          .select('position')
          .eq('playlist_id', playlistId)
          .order('position', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 0;
      }

      return (response.first['position'] as int) + 1;
    } catch (e) {
      rethrow;
    }
  }
}

