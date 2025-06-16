import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/playlist.dart';
import '../../controller/playlist_controller.dart';
import '../../models/playlist_repository.dart';
import '../../models/playlist_songs_link.dart';

class EditPlaylistDialog extends StatefulWidget {
  final Playlist playlist;
  final Function(Playlist) onPlaylistUpdated;

  const EditPlaylistDialog({
    super.key,
    required this.playlist,
    required this.onPlaylistUpdated,
  });

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.playlist.title);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Editar Playlist',
                    style: AppTextStyles.headlineSmall(),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.button(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.trim().isNotEmpty) {
                      try {
                        final Playlist updatedPlaylist = widget.playlist.copyWith(
                          title: _titleController.text.trim(),
                        );
                        
                        final PlaylistController playlistController = PlaylistController(
                          playlistRepository: PlaylistRepository(),
                          playlistSongRepo: PlaylistSongRepository(),
                          currentUserId: widget.playlist.ownerId,
                        );
                        
                        await playlistController.updatePlaylist(updatedPlaylist);
                        
                        widget.onPlaylistUpdated(updatedPlaylist);
                        Navigator.pop(context);
                      
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Playlist atualizada!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao atualizar playlist: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Salvar', style: AppTextStyles.button()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

