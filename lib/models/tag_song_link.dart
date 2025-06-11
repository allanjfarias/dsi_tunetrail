import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

class TagSongLinkRepository {
  final SupabaseClient supabase;

  TagSongLinkRepository({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<void> linkTagToSong(String tagId, String songId) async {
    try {
      await supabase.from('tags_songs').insert(<String, String>{
        'tag_id': tagId,
        'song_id': songId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkTagFromSong(String tagId, String songId) async {
    try {
      await supabase
          .from('tags_songs')
          .delete()
          .eq('tag_id', tagId)
          .eq('song_id', songId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Song>> fetchSongsByTag(String tagId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
          .select('song:song_id(*)')
          .eq('tag_id', tagId);

      final List<Song> songs =
          response
              .map(
                (dynamic row) =>
                    Song.fromJson(row['song'] as Map<String, dynamic>),
              )
              .toList();

      return songs;
    } catch (e) {
      rethrow;
    }
  }
}
