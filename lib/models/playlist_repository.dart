import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tunetrail/models/playlist.dart';
import 'package:tunetrail/models/crud_repository.dart';

class PlaylistRepository extends CrudRepository<Playlist> {
  PlaylistRepository({
    SupabaseClient? supabaseClient,
  }) : super(
          table: 'playlists',
          fromJson: Playlist.fromJson,
          toJson: (playlist) => playlist.toJson(),
          supabaseClient: supabaseClient,
        );

  Future<List<Playlist>> readByOwnerId(String ownerId) async {
    try {
      final List<Map<String, dynamic>> result = await supabase
          .from(table)
          .select()
          .eq('owner_id', ownerId);
      return (result as List<dynamic>)
          .map((dynamic e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}


