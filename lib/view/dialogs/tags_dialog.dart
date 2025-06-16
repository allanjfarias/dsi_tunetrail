import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/song.dart';
import '../../models/tag.dart';
import '../../controller/tag_controller.dart';

class TagsDialog extends StatefulWidget {
  final Song song;
  final TagController tagController;
  final String userId;

  const TagsDialog({
    super.key,
    required this.song,
    required this.tagController,
    required this.userId,
  });

  @override
  State<TagsDialog> createState() => _TagsDialogState();
}

class _TagsDialogState extends State<TagsDialog> {
  List<Tag> _allTags = <Tag>[];
  List<String> _songTagIds = <String>[];
  bool _isLoading = true;
  final TextEditingController _newTagController = TextEditingController();
  Tag? _editingTag;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final List<Tag> allTags = await widget.tagController.getAllTags();
      final List<Tag> songTags = await widget.tagController.fetchTagsBySong(widget.song.songId);
      final List<String> songTagIds = songTags.map((Tag tag) => tag.id!).toList();
      
      setState(() {
        _allTags = allTags;
        _songTagIds = songTagIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTag(String name) async {
    try {
      final Tag newTag = Tag(
        name: name,
        userId: widget.userId,
      );
      
      final Tag createdTag = await widget.tagController.createTag(newTag);
      setState(() {
        _allTags.add(createdTag);
      });
      
      _newTagController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag criada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar tag: $e')),
      );
    }
  }

  Future<void> _updateTag(Tag tag, String newName) async {
    try {
      final Tag updatedTag = tag.copyWith(name: newName);
      await widget.tagController.updateTag(tag.id!, updatedTag);
      
      setState(() {
        final int index = _allTags.indexWhere((Tag t) => t.id == tag.id);
        if (index != -1) {
          _allTags[index] = updatedTag;
        }
        _editingTag = null;
      });
      
      _newTagController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag atualizada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar tag: $e')),
      );
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Excluir tag', style: AppTextStyles.headlineSmall()),
        content: Text('Tem certeza que deseja excluir a tag "${tag.name}"?', style: AppTextStyles.bodyMedium()),
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
        await widget.tagController.deleteTag(tag.id!);
        setState(() {
          _allTags.removeWhere((Tag t) => t.id == tag.id);
          _songTagIds.remove(tag.id);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag excluída com sucesso!')),
        );
      } catch (e) {if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir tag: $e')),
        );
      }
    }
  }

  Future<void> _toggleTag(Tag tag) async {
    try {
      final bool isLinked = _songTagIds.contains(tag.id);
      
      if (isLinked) {
        await widget.tagController.unlinkTagFromSong(tag.id!, widget.song.songId);
        setState(() {
          _songTagIds.remove(tag.id);
        });
      } else {
        await widget.tagController.linkTagToSong(tag.id!, widget.song.songId);
        setState(() {
          _songTagIds.add(tag.id!);
        });
      }
    } catch (e) {if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar tag: $e')),
      );
    }
  }

  void _startEditing(Tag tag) {
    setState(() {
      _editingTag = tag;
      _newTagController.text = tag.name;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingTag = null;
      _newTagController.clear();
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
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Tags para "${widget.song.name}"',
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
                    controller: _newTagController,
                    decoration: InputDecoration(
                      hintText: _editingTag != null ? 'Editando tag...' : 'Nova tag...',
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
                ElevatedButton(
                  onPressed: () {
                    if (_newTagController.text.trim().isNotEmpty) {
                      if (_editingTag != null) {
                        _updateTag(_editingTag!, _newTagController.text.trim());
                      } else {
                        _createTag(_newTagController.text.trim());
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _editingTag != null ? 'Salvar' : 'Criar',
                    style: AppTextStyles.button(),
                  ),
                ),
                if (_editingTag != null)
                  TextButton(
                    onPressed: _cancelEditing,
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.button(color: AppColors.textSecondary),
                    ),
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
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _allTags.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Tag tag = _allTags[index];
                    final bool isSelected = _songTagIds.contains(tag.id);
                    final bool isOwner = tag.userId == widget.userId;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          tag.name,
                          style: AppTextStyles.bodyMedium(
                            color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                            ),
                            if (isOwner)
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                                color: AppColors.background,
                                onSelected: (String value) {
                                  switch (value) {
                                    case 'edit':
                                      _startEditing(tag);
                                      break;
                                    case 'delete':
                                      _deleteTag(tag);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.edit, size: 16, color: AppColors.primaryColor),
                                        const SizedBox(width: 8),
                                        Text('Editar', style: AppTextStyles.bodyMedium()),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.delete, size: 16, color: AppColors.error),
                                        const SizedBox(width: 8),
                                        Text('Excluir', style: AppTextStyles.bodyMedium(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        onTap: () => _toggleTag(tag),
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
    _newTagController.dispose();
    super.dispose();
  }
}