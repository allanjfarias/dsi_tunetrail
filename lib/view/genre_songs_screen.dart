import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunetrail/controller/auth_controller.dart';
import 'package:tunetrail/controller/comments_controller.dart';
import 'package:tunetrail/models/comments.dart';
import 'package:tunetrail/models/crud_repository.dart';
import 'dialogs/comments_dialog.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/song_repository.dart';
import '../models/song.dart';

class GenreSongsScreen extends StatefulWidget {
  final String genre;
  const GenreSongsScreen({super.key, required this.genre});

  @override
  State<GenreSongsScreen> createState() => _GenreSongsScreenState();
}

class _GenreSongsScreenState extends State<GenreSongsScreen> {
  final SongRepository _songRepository = SongRepository();
  final AuthController _authController = AuthController();
  late final CommentController _commentController;
  late Future<List<Song>> _genreSongsFuture;

  void _showCommentsDialog(Song song) {
    showDialog(
      context: context,
      builder: (context) => CommentsDialog(
        song: song,
        commentController: _commentController, 
        userId: _authController.usuarioLogado!.id),
    );
  }

  @override
  void initState() {
    super.initState();
    _genreSongsFuture = _songRepository.fetchSongsByGenre(widget.genre);
    _commentController = CommentController(
      CrudRepository<Comment>(
        table: 'comments',
        fromJson: Comment.fromJson,
        toJson: (Comment c) => c.toJson(),
      ),
    );
  }

  String _formatArtists(String artists) {
    return artists.replaceAll(';', ', ');
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(widget.genre, style: AppTextStyles.headlineMedium()),
      ),
      body: FutureBuilder<List<Song>>(
        future: _genreSongsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar músicas: ${snapshot.error}', style: AppTextStyles.bodyMedium(color: AppColors.error)));
          }
          final List<Song> songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return Center(child: Text('Nenhuma música encontrada neste gênero.', style: AppTextStyles.bodyLarge(color: AppColors.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final Song song = songs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: song.coverUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.inputBackground),
                      errorWidget: (context, url, error) => const Icon(Icons.music_note, color: AppColors.textSecondary),
                    ),
                  ),
                  title: Text(song.name, style: AppTextStyles.subtitleMedium(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(_formatArtists(song.artist), style: AppTextStyles.bodyMedium(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    _showCommentsDialog(song);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}