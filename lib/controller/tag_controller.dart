import '../models/tag.dart';
import '../models/crud_repository.dart';
import '../models/tag_song_link.dart';
import '../models/song.dart';

class TagController {
  final CrudRepository<Tag> _tagRepository;
  final TagSongLinkRepository _tagSongLinkRepository;

  TagController(this._tagRepository, this._tagSongLinkRepository);

  Future<List<Tag>> getAllTags() async {
    return await _tagRepository.readAll();
  }

  Future<Tag?> getTagById(String id) async {
    return await _tagRepository.readOne(id);
  }

  Future<Tag> createTag(Tag tag) async {
    return await _tagRepository.create(tag);
  }

  Future<Tag> updateTag(String id, Tag tag) async {
    return await _tagRepository.update(id, tag);
  }

  Future<void> deleteTag(String id) async {
    // CORREÇÃO: Primeiro remover todas as associações da tag com músicas
    await _tagSongLinkRepository.removeAllLinksForTag(id);
    // Depois excluir a tag
    await _tagRepository.delete(id);
  }

  // CORREÇÃO: Método corrigido para evitar duplicatas
  Future<void> linkTagToSong(String tagId, String songId) async {
    try {
      // Verificar se a associação já existe antes de criar
      final bool exists = await _tagSongLinkRepository.isTagLinkedToSong(tagId, songId);
      if (!exists) {
        await _tagSongLinkRepository.linkTagToSong(tagId, songId);
      }
    } catch (e) {
      // Se der erro de chave duplicada, ignorar (associação já existe)
      if (!e.toString().contains('duplicate key value violates unique constraint')) {
        rethrow;
      }
    }
  }

  Future<void> unlinkTagFromSong(String tagId, String songId) async {
    await _tagSongLinkRepository.unlinkTagFromSong(tagId, songId);
  }

  // CORREÇÃO: Método corrigido para buscar tags de uma música específica
  Future<List<Tag>> fetchTagsBySong(String songId) async {
    return await _tagSongLinkRepository.fetchTagsBySong(songId);
  }

  Future<List<Song>> fetchSongsByTag(String tagId) async {
    return await _tagSongLinkRepository.fetchSongsByTag(tagId);
  }

  // CORREÇÃO: Método para buscar tags do usuário
  Future<List<Tag>> getTagsByUser(String userId) async {
    final List<Tag> allTags = await getAllTags();
    return allTags.where((Tag tag) => tag.userId == userId).toList();
  }

  // CORREÇÃO: Método para verificar se uma tag pode ser editada/excluída pelo usuário
  bool canUserModifyTag(Tag tag, String userId) {
    return tag.userId == userId;
  }
}