import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';
import '../models/tag.dart';

class TagSongLinkRepository {
  final SupabaseClient supabase;

  TagSongLinkRepository({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<void> linkTagToSong(String tagId, String songId) async {
    try {
      final bool exists = await isTagLinkedToSong(tagId, songId);
      if (!exists) {
        await supabase.from('tags_songs').insert(<String, String>{
          'tag_id': tagId,
          'song_id': songId,
        });
      }
    } catch (e) {
      if (!e.toString().contains('duplicate key value violates unique constraint')) {
        rethrow;
      }
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

  Future<void> removeAllLinksForTag(String tagId) async {
    try {
      await supabase
          .from('tags_songs')
          .delete()
          .eq('tag_id', tagId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isTagLinkedToSong(String tagId, String songId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
          .select('id')
          .eq('tag_id', tagId)
          .eq('song_id', songId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Song>> fetchSongsByTag(String tagId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
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
            )
          ''')
          .eq('tag_id', tagId);

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

  Future<List<Tag>> fetchTagsBySong(String songId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
          .select('''
            tags!inner(
              id,
              name,
              user_id,
              created_at,
              updated_at
            )
          ''')
          .eq('song_id', songId);

      return response.map((Map<String, dynamic> row) {
        final Map<String, dynamic> tagData = row['tags'] as Map<String, dynamic>;
        return Tag.fromJson(tagData);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchSongIdsByTag(String tagId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
          .select('song_id')
          .eq('tag_id', tagId);

      return response.map((Map<String, dynamic> row) => row['song_id'] as String).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchTagIdsBySong(String songId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
          .select('tag_id')
          .eq('song_id', songId);

      return response.map((Map<String, dynamic> row) => row['tag_id'] as String).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLinked(String tagId, String songId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tags_songs')
          .select('id')
          .eq('tag_id', tagId)
          .eq('song_id', songId);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}