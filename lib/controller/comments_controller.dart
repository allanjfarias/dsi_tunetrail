import '../models/crud_repository.dart';
import '../models/comments.dart';

class CommentController {
  final CrudRepository<Comment> _repository;

  CommentController(this._repository);

  Future<void> addComment(Comment comment) async {
    await _repository.create(comment);
  }

  Future<List<Comment>> fetchCommentsByMusicId(String songId) async {
    final List<Comment> allComments = await _repository.readAll();
    return allComments.where((Comment c) => c.songId == songId).toList();
  }

  Future<List<Comment>> fetchCommentsByUserId(String userId) async {
    final List<Comment> allComments = await _repository.readAll();
    return allComments.where((Comment c) => c.userId == userId).toList();
  }

  Future<void> deleteComment(String id) async {
    await _repository.delete(id);
  }

  Future<Comment?> getComment(String id) async {
    return await _repository.readOne(id);
  }

  Future<void> updateComment(String id, Comment updatedComment) async {
    await _repository.update(id, updatedComment);
  }
}
