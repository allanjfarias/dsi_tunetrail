import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

class SongRepository {
  final SupabaseClient supabase;

  SongRepository({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<List<Song>> searchSongs(String query) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('songs')
          .select('*, covers(image_url)')
          .ilike('track_name', '%$query%')
          .limit(10);
      return response.map(Song.fromJson).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Song>> fetchPopularSongs() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('songs')
          .select('*, covers(image_url)')
          .order('popularity', ascending: false)
          .limit(10);
      return response.map(Song.fromJson).toList();
    } catch (e) {
      rethrow;
    }
  }
}