import 'package:flutter/material.dart';
import 'package:tunetrail/models/user.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/auth_controller.dart';
import '../controller/playlist_controller.dart';
import '../models/playlist_repository.dart';
import '../models/playlist_songs_link.dart';
import '../models/playlist.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final AuthController _authController = AuthController();
  final PlaylistController _playlistController = PlaylistController(
    playlistRepository: PlaylistRepository(),
    playlistSongRepo: PlaylistSongRepository(),
    currentUserId: AuthController().usuarioLogado!.id,
  );
  final TextEditingController _nameController = TextEditingController();
  
  bool _isCreating = false;

  Future<void> _createPlaylist() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome da playlist não pode estar vazio')),
      );
      return;
    }

    final User? user = _authController.usuarioLogado;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final Playlist playlist = Playlist(
        title: _nameController.text.trim(),
        ownerId: user.id,
      );

      await _playlistController.playlistRepository.create(playlist);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playlist criada com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar playlist: $e')),
      );
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
          'Criar playlist',
          style: AppTextStyles.headlineMedium(color: AppColors.primaryColor),
        ),
        actions: <Widget>[
          if (_isCreating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createPlaylist,
              child: Text(
                'Criar',
                style: AppTextStyles.button(color: AppColors.primaryColor),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Playlist Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[AppColors.cardShadow],
                ),
                child: const Icon(
                  Icons.queue_music,
                  size: 60,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Nome da Playlist Field
            Text(
              'Nome da playlist',
              style: AppTextStyles.subtitleMedium(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTextStyles.inputText(),
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Digite o nome da sua playlist',
                hintStyle: AppTextStyles.hintText(),
                filled: true,
                fillColor: AppColors.card,
                counterStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Descrição
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sobre as playlists',
                        style: AppTextStyles.subtitleMedium(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Organize suas músicas favoritas em playlists personalizadas\n'
                    '• Adicione e remova músicas a qualquer momento\n'
                    '• Crie quantas playlists quiser',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Create Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createPlaylist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Criar playlist',
                        style: AppTextStyles.button().copyWith(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}