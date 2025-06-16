import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/auth_controller.dart';
import '../controller/playlist_controller.dart';
import '../controller/tag_controller.dart';
import '../controller/comments_controller.dart';
import '../models/playlist_repository.dart';
import '../models/playlist_songs_link.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../models/tag.dart';
import '../models/comments.dart';
import '../models/crud_repository.dart';
import '../models/tag_song_link.dart';
import 'buscar_screen.dart';
import 'dialogs/edit_playlist_dialog.dart';
import 'dialogs/tags_dialog.dart';
import 'dialogs/comments_dialog.dart';
import 'playlist_details/song_card.dart';
import 'playlist_details/reorderable_song_card.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  final AuthController _authController = AuthController();
  late final PlaylistController _playlistController;
  late final TagController _tagController;
  late final CommentController _commentController;
  
  List<Song> _songs = <Song>[];
  bool _isLoading = true;
  bool _isReordering = false;
  late Playlist _currentPlaylist;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
    _playlistController = PlaylistController(
      playlistRepository: PlaylistRepository(),
      playlistSongRepo: PlaylistSongRepository(),
      currentUserId: _authController.usuarioLogado!.id,
    );
    
    _tagController = TagController(
      CrudRepository<Tag>(
        table: 'tags',
        fromJson: Tag.fromJson,
        toJson: (Tag tag) => tag.toJson(),
      ),
      TagSongLinkRepository(),
    );
    
    _commentController = CommentController(
      CrudRepository<Comment>(
        table: 'comments',
        fromJson: Comment.fromJson,
        toJson: (Comment comment) => comment.toJson(),
      ),
    );
    
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      if (_currentPlaylist.id != null) {
        final List<Song> songs = await _playlistController.fetchSongsFromPlaylist(_currentPlaylist.id!);
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar músicas: $e')),
      );
    }
  }

  Future<void> _removeSongFromPlaylist(Song song) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Remover música',
            style: AppTextStyles.headlineSmall(),
          ),
          content: Text(
            'Tem certeza que deseja remover "${song.name}" da playlist?',
            style: AppTextStyles.bodyMedium(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: AppTextStyles.button(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Remover',
                style: AppTextStyles.button(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && _currentPlaylist.id != null) {
      try {
        await _playlistController.removeSongFromPlaylist(_currentPlaylist.id!, song.songId);
        setState(() {
          _songs.removeWhere((Song s) => s.songId == song.songId);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Música removida da playlist!')),
        );
      } catch (e) {if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover música: $e')),
        );
      }
    }
  }

  Future<void> _addSongToPlaylist() async {
    final Song? selectedSong = await Navigator.push<Song>(
      context,
      MaterialPageRoute<Song>(
        builder: (BuildContext context) => const BuscarScreen(selectMode: true),
      ),
    );

    if (selectedSong != null && _currentPlaylist.id != null) {
      try {
        final bool songExists = _songs.any((Song s) => s.songId == selectedSong.songId);
        if (songExists) {if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Esta música já está na playlist!')),
          );
          return;
        }
        
        await _playlistController.addSongToPlaylist(_currentPlaylist.id!, selectedSong.songId);
        setState(() {
          _songs.add(selectedSong);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Música adicionada à playlist!')),
        );
      } catch (e) {if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar música: $e')),
        );
      }
    }
  }

  void _toggleReorderMode() {
    setState(() {
      _isReordering = !_isReordering;
    });
  }

  Future<void> _reorderSongs(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final Song song = _songs.removeAt(oldIndex);
      _songs.insert(newIndex, song);
    });

    if (_currentPlaylist.id != null) {
      try {
        final List<String> songIds = _songs.map((Song s) => s.songId).toList();
        await _playlistController.reorderPlaylistSongs(_currentPlaylist.id!, songIds);
      } catch (e) {if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reordenar músicas: $e')),
        );
        _loadSongs();
      }
    }
  }

  Future<void> _showTagsDialog(Song song) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => TagsDialog(
        song: song,
        tagController: _tagController,
        userId: _authController.usuarioLogado!.id,
      ),
    );
  }

  Future<void> _showCommentsDialog(Song song) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CommentsDialog(
        song: song,
        commentController: _commentController,
        userId: _authController.usuarioLogado!.id,
      ),
    );
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final String fileName = 'playlist_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'playlist_covers/$fileName';
      
      await Supabase.instance.client.storage
          .from('playlist-covers')
          .upload(filePath, imageFile);
      
      final String publicUrl = Supabase.instance.client.storage
          .from('playlist-covers')
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _editPlaylistCover() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
        
        final File imageFile = File(image.path);
        final String? uploadedUrl = await _uploadImageToSupabase(imageFile);
        
        if (!mounted) return;
        Navigator.pop(context);
        
        if (uploadedUrl != null) {
          final Playlist updatedPlaylist = _currentPlaylist.copyWith(coverUrl: uploadedUrl);
          await _playlistController.updatePlaylist(updatedPlaylist);
          
          setState(() {
            _currentPlaylist = updatedPlaylist;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Capa da playlist atualizada!')),
          );
        } else {if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao fazer upload da imagem')),
          );
        }
      } catch (e) {if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar capa: $e')),
        );
      }
    }
  }

  Future<void> _editPlaylist() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => EditPlaylistDialog(
        playlist: _currentPlaylist,
        onPlaylistUpdated: (Playlist updatedPlaylist) {
          setState(() {
            _currentPlaylist = updatedPlaylist;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSliverAppBar(),
          _buildPlaylistInfo(),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              : _songs.isEmpty
                  ? _buildEmptyState()
                  : _buildSongsList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final bool isOwner = _currentPlaylist.ownerId == _authController.usuarioLogado!.id;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
        ),
      ),
      actions: <Widget>[
        if (isOwner)
          IconButton(
            onPressed: _editPlaylist,
            icon: const Icon(
              Icons.edit,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        if (_songs.isNotEmpty)
          IconButton(
            onPressed: _toggleReorderMode,
            icon: Icon(
              _isReordering ? Icons.check : Icons.reorder,
              color: _isReordering ? const Color.fromARGB(255, 156, 253, 159) : AppColors.textPrimary,
              size: 28,
            ),
          ),
        IconButton(
          onPressed: _addSongToPlaylist,
          icon: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 156, 253, 159),
            size: 28,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.primaryColor.withValues(alpha: 0.8),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: isOwner ? _editPlaylistCover : null,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _currentPlaylist.coverUrl != null && _currentPlaylist.coverUrl!.isNotEmpty
                          ? Image.network(
                              _currentPlaylist.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _buildDefaultCover(),
                            )
                          : _buildDefaultCover(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.queue_music,
        size: 80,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPlaylistInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _currentPlaylist.title,
              style: AppTextStyles.headlineLarge(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (_currentPlaylist.ownerFullName != null)
              Row(
                children: <Widget>[
                  if (_currentPlaylist.ownerAvatarUrl != null && _currentPlaylist.ownerAvatarUrl!.isNotEmpty)
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(_currentPlaylist.ownerAvatarUrl!),
                      backgroundColor: AppColors.primaryColor,
                    )
                  else
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _currentPlaylist.ownerFullName!,
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Icon(
                  Icons.music_note,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_songs.length} ${_songs.length == 1 ? 'música' : 'músicas'}',
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 60,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Playlist vazia',
                style: AppTextStyles.headlineSmall(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione suas primeiras músicas para começar a construir sua playlist',
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addSongToPlaylist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Adicionar primeira música',
                    style: AppTextStyles.button().copyWith(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    if (_isReordering) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo de reordenação ativo. Toque e arraste as músicas para reordená-las.',
                        style: AppTextStyles.bodyMedium(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _songs.length,
                onReorder: _reorderSongs,
                itemBuilder: (BuildContext context, int index) {
                  final Song song = _songs[index];
                  return ReorderableSongCard(
                    key: Key(song.songId),
                    song: song,
                    index: index,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final Song song = _songs[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
              top: index == 0 ? 8.0 : 0,
            ),
            child: SongCard(
              song: song,
              index: index,
              onTagsPressed: () => _showTagsDialog(song),
              onCommentsPressed: () => _showCommentsDialog(song),
              onRemovePressed: () => _removeSongFromPlaylist(song),
            ),
          );
        },
        childCount: _songs.length,
      ),
    );
  }
}