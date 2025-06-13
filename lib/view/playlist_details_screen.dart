import 'package:flutter/material.dart';
import 'package:tunetrail/models/user.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/auth_controller.dart';
import '../controller/playlist_controller.dart';
import '../models/playlist_repository.dart';
import '../models/playlist_songs_link.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import 'buscar_screen.dart';

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
  
  List<Song> _songs = <Song>[];
  bool _isLoading = true;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _playlistController = PlaylistController(
      playlistRepository: PlaylistRepository(),
      playlistSongRepo: PlaylistSongRepository(),
      currentUserId: _authController.usuarioLogado!.id,
    );
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      if (widget.playlist.id != null) {
        final List<Song> songs = await _playlistController.fetchSongsFromPlaylist(widget.playlist.id!);
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

    if (confirm == true && widget.playlist.id != null) {
      try {
        await _playlistController.removeSongFromPlaylist(widget.playlist.id!, song.songId);
        setState(() {
          _songs.removeWhere((Song s) => s.songId == song.songId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Música removida da playlist!')),
        );
      } catch (e) {
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

    if (selectedSong != null && widget.playlist.id != null) {
      try {
        // Verificar se a música já está na playlist
        final bool songExists = _songs.any((Song s) => s.songId == selectedSong.songId);
        if (songExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Esta música já está na playlist!')),
          );
          return;
        }
        
        print('DEBUG: songId sendo adicionado: ${selectedSong.songId}'); // Adicionado para depuração

        await _playlistController.addSongToPlaylist(widget.playlist.id!, selectedSong.songId);
        setState(() {
          _songs.add(selectedSong);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Música adicionada à playlist!')),
        );
      } catch (e) {
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

    // Atualizar as posições no banco de dados
    if (widget.playlist.id != null) {
      try {
        final List<String> songIds = _songs.map((Song s) => s.songId).toList();
        await _playlistController.reorderPlaylistSongs(widget.playlist.id!, songIds);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reordenar músicas: $e')),
        );
        // Recarregar a lista em caso de erro
        _loadSongs();
      }
    }
  }

  String _formatDuration(double durationMs) {
    final int totalSeconds = (durationMs / 1000).round();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          widget.playlist.title,
          style: AppTextStyles.headlineMedium(color: AppColors.primaryColor),
        ),
        actions: <Widget>[
          if (_songs.isNotEmpty)
            IconButton(
              onPressed: _toggleReorderMode,
              icon: Icon(
                _isReordering ? Icons.check : Icons.reorder,
                color: _isReordering ? AppColors.success : AppColors.primaryColor,
                size: 28,
              ),
            ),
          IconButton(
            onPressed: _addSongToPlaylist,
            icon: const Icon(
              Icons.add,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : _songs.isEmpty
              ? _buildEmptyState()
              : _buildSongsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildSongsList() {
    if (_isReordering) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _songs.length,
        onReorder: _reorderSongs,
        itemBuilder: (BuildContext context, int index) {
          final Song song = _songs[index];
          return _buildReorderableSongCard(song, index);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _songs.length,
      itemBuilder: (BuildContext context, int index) {
        final Song song = _songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildSongCard(song, index),
        );
      },
    );
  }

  Widget _buildSongCard(Song song, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[AppColors.cardShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bodyMedium(color: AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
        title: Text(
          song.name,
          style: AppTextStyles.subtitleLarge(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              song.artist,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Text(
                  song.album,
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  _formatDuration(song.duration),
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.textSecondary,
          ),
          color: AppColors.card,
          onSelected: (String value) {
            switch (value) {
              case 'remove':
                _removeSongFromPlaylist(song);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'remove',
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Remover da playlist',
                    style: AppTextStyles.bodyMedium(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableSongCard(Song song, int index) {
    return Container(
      key: ValueKey(song.songId),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[AppColors.cardShadow],
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.drag_handle,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bodyMedium(color: AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
        title: Text(
          song.name,
          style: AppTextStyles.subtitleLarge(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

