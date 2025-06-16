import 'package:flutter/material.dart';
import 'package:tunetrail/models/user.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/auth_controller.dart';
import '../controller/playlist_controller.dart';
import '../models/playlist_repository.dart';
import '../models/playlist_songs_link.dart';
import '../models/playlist.dart';
import 'playlist_details_screen.dart';

class MyPlaylistsScreen extends StatefulWidget {
  const MyPlaylistsScreen({super.key});

  @override
  State<MyPlaylistsScreen> createState() => _MyPlaylistsScreenState();
}

class _MyPlaylistsScreenState extends State<MyPlaylistsScreen> {
  final AuthController _authController = AuthController();
  final PlaylistController _playlistController = PlaylistController(
    playlistRepository: PlaylistRepository(),
    playlistSongRepo: PlaylistSongRepository(),
    currentUserId: AuthController().usuarioLogado!.id,
  );
  
  List<Playlist> _playlists = <Playlist>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      final User? user = _authController.usuarioLogado;
      if (user != null) {
        final List<Playlist> playlists = await _playlistController.playlistRepository.readByOwnerId(user.id);
        setState(() {
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar playlists: $e')),
      );
    }
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Excluir playlist',
            style: AppTextStyles.headlineSmall(),
          ),
          content: Text(
            'Tem certeza que deseja excluir a playlist "${playlist.title}"?',
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
                'Excluir',
                style: AppTextStyles.button(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && playlist.id != null) {
      try {
        await _playlistController.playlistRepository.delete(playlist.id!);
        setState(() {
          _playlists.removeWhere((Playlist p) => p.id == playlist.id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist excluída com sucesso!')),
        );
      } catch (e) {if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir playlist: $e')),
        );
      }
    }
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
          'Minhas playlists',
          style: AppTextStyles.headlineMedium(color: AppColors.primaryColor),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create_playlist').then((_) {
                _loadPlaylists();
              });
            },
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
          : _playlists.isEmpty
              ? _buildEmptyState()
              : _buildPlaylistsList(),
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
                Icons.queue_music,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma playlist encontrada',
              style: AppTextStyles.headlineSmall(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie sua primeira playlist para começar a organizar suas músicas favoritas',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_playlist').then((_) {
                    _loadPlaylists();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Criar primeira playlist',
                  style: AppTextStyles.button().copyWith(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _playlists.length,
      itemBuilder: (BuildContext context, int index) {
        final Playlist playlist = _playlists[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildPlaylistCard(playlist),
        );
      },
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[AppColors.cardShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildPlaylistCover(playlist),
          ),
        ),
        title: Text(
          playlist.title,
          style: AppTextStyles.subtitleLarge(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Playlist pessoal',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.textSecondary,
          ),
          color: AppColors.card,
          onSelected: (String value) {
            switch (value) {
              case 'delete':
                _deletePlaylist(playlist);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Excluir',
                    style: AppTextStyles.bodyMedium(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => PlaylistDetailsScreen(playlist: playlist),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistCover(Playlist playlist) {
    if (playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty) {
      return Image.network(
        playlist.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _buildDefaultCover(),
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.textPrimary,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      return _buildDefaultCover();
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.queue_music,
        color: AppColors.textPrimary,
        size: 30,
      ),
    );
  }
}