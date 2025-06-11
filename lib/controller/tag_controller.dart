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
    await _tagRepository.delete(id);
  }

  Future<void> linkTagToSong(String tagId, String songId) async {
    await _tagSongLinkRepository.linkTagToSong(tagId, songId);
  }

  Future<void> unlinkTagFromSong(String tagId, String songId) async {
    await _tagSongLinkRepository.unlinkTagFromSong(tagId, songId);
  }

  Future<List<Song>> fetchSongsByTag(String tagId) async {
    return await _tagSongLinkRepository.fetchSongsByTag(tagId);
  }
}
