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
          .select('''
            songs!inner(
              id,
              track_name,
              artists,
              album_name,
              duration_ms,
              track_genre,
              popularity,
              explicit,
              covers(image_url)
            ),
            position
          ''')
          .eq('playlist_id', playlistId)
          .order('position');

      return response.map((Map<String, dynamic> row) {
        final Map<String, dynamic> songData = row['songs'] as Map<String, dynamic>;
        if (songData['covers'] != null) {
          songData['cover_url'] = songData['covers']['image_url'];
        }
        return Song.fromJson(songData);
      }).toList();
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
      return 0;
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
}