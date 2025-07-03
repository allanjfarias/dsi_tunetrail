import 'package:http/http.dart';
import 'package:tunetrail/models/playlist.dart';
import 'package:tunetrail/models/crud_repository.dart';

class PlaylistRepository extends CrudRepository<Playlist> {
  PlaylistRepository({
    super.supabaseClient,
  }) : super(
          table: 'playlists',
          fromJson: Playlist.fromJson,
          toJson: (Playlist playlist) => playlist.toJson(),
        );

  @override
  Future<List<Playlist>> readAll() async {
    try {
      final List<Map<String, dynamic>> result = await supabase
          .from(table)
          .select('''
            *,
            profiles!inner(nome, foto_url)
          ''');
      return (result as List<dynamic>).map((dynamic item) {
        final Map<String, dynamic> playlistData = item as Map<String, dynamic>;
        final Map<String, dynamic>? profileData = playlistData['profiles'] as Map<String, dynamic>?;
        
        return fromJson(<String, dynamic>{
          ...playlistData,
          'owner_name': profileData?['nome'],
          'owner_avatar_url': profileData?['foto_url'],
        });
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Playlist>> readByOwnerId(String ownerId) async {
    try {
      final List<Map<String, dynamic>> result = await supabase
          .from(table)
          .select('''
            *,
            profiles!inner(nome, foto_url)
          ''')
          .eq('owner_id', ownerId);
      return (result as List<dynamic>).map((dynamic item) {
        final Map<String, dynamic> playlistData = item as Map<String, dynamic>;
        final Map<String, dynamic>? profileData = playlistData['profiles'] as Map<String, dynamic>?;
        
        return fromJson(<String, dynamic>{
          ...playlistData,
          'owner_name': profileData?['nome'],
          'owner_avatar_url': profileData?['foto_url'],
        });
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Playlist>> fetchUserPlaylists(String userId) async {
    try {
      final response = await supabase
        .from('playlists')
        .select()
        .eq('owner_id', userId)
        .order('title', ascending: true);
      return (response as List).map((e) => Playlist.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar playlists do usuário: $e');
    }
  }

}

