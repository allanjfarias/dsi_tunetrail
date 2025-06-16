import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/song.dart';
import '../../models/comments.dart';
import '../../controller/comments_controller.dart';

class CommentsDialog extends StatefulWidget {
  final Song song;
  final CommentController commentController;
  final String userId;

  const CommentsDialog({
    super.key,
    required this.song,
    required this.commentController,
    required this.userId,
  });

  @override
  State<CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  List<Comment> _comments = <Comment>[];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  Comment? _editingComment;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final List<Comment> comments = await widget.commentController.fetchCommentsByMusicId(widget.song.songId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    try {
      final Comment newComment = Comment(
        content: _commentController.text.trim(),
        songId: widget.song.songId,
        userId: widget.userId,
      );
      
      await widget.commentController.addComment(newComment);
      _commentController.clear();
      _loadComments();
    } catch (e) {if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar comentário: $e')),
      );
    }
  }

  Future<void> _editComment(Comment comment) async {
    if (_commentController.text.trim().isEmpty) return;
    
    try {
      final Comment updatedComment = comment.copyWith(
        content: _commentController.text.trim(),
      );
      
      await widget.commentController.updateComment(comment.id!, updatedComment);
      _commentController.clear();
      setState(() {
        _editingComment = null;
      });
      _loadComments();
    } catch (e) {if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao editar comentário: $e')),
      );
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Excluir comentário', style: AppTextStyles.headlineSmall()),
        content: Text('Tem certeza que deseja excluir este comentário?', style: AppTextStyles.bodyMedium()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: AppTextStyles.button(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir', style: AppTextStyles.button(color: AppColors.error)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await widget.commentController.deleteComment(comment.id!);
        _loadComments();
      } catch (e) {if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir comentário: $e')),
        );
      }
    }
  }

  void _startEditing(Comment comment) {
    setState(() {
      _editingComment = comment;
      _commentController.text = comment.content;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingComment = null;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Comentários - "${widget.song.name}"',
                    style: AppTextStyles.headlineSmall(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: _editingComment != null ? 'Editando comentário...' : 'Escreva um comentário...',
                      hintStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.textSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                    style: AppTextStyles.bodyMedium(),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _editingComment != null ? () => _editComment(_editingComment!) : _addComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _editingComment != null ? 'Salvar' : 'Enviar',
                        style: AppTextStyles.button(),
                      ),
                    ),
                    if (_editingComment != null)
                      TextButton(
                        onPressed: _cancelEditing,
                        child: Text(
                          'Cancelar',
                          style: AppTextStyles.button(color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                ),
              )
            else if (_comments.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.comment_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum comentário ainda',
                        style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
                      ),
                      Text(
                        'Seja o primeiro a comentar!',
                        style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Comment comment = _comments[index];
                    final bool isOwner = comment.userId == widget.userId;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              if (comment.userAvatarUrl != null && comment.userAvatarUrl!.isNotEmpty)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(comment.userAvatarUrl!),
                                  backgroundColor: AppColors.primaryColor,
                                )
                              else
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryColor,
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  comment.userName ?? 'Usuário',
                                  style: AppTextStyles.subtitleMedium(),
                                ),
                              ),
                              if (isOwner)
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                                  color: AppColors.card,
                                  onSelected: (String value) {
                                    switch (value) {
                                      case 'edit':
                                        _startEditing(comment);
                                        break;
                                      case 'delete':
                                        _deleteComment(comment);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.edit, size: 16, color: AppColors.primaryColor),
                                            const SizedBox(width: 8),
                                            Text('Editar', style: AppTextStyles.bodyMedium(color: AppColors.primaryColor)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.delete, size: 16, color: AppColors.error),
                                            const SizedBox(width: 8),
                                            Text('Excluir', style: AppTextStyles.bodyMedium(color: AppColors.error)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.content,
                            style: AppTextStyles.bodyMedium(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}