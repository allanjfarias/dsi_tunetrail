
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/song.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final int index;
  final VoidCallback onTagsPressed;
  final VoidCallback onCommentsPressed;
  final VoidCallback onRemovePressed;

  const SongCard({
    super.key,
    required this.song,
    required this.index,
    required this.onTagsPressed,
    required this.onCommentsPressed,
    required this.onRemovePressed,
  });

  String _formatDuration(double durationMs) {
    final int totalSeconds = (durationMs / 1000).round();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatArtists(String artists) {
    return artists.replaceAll(';', ', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[AppColors.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.bodyMedium(color: AppColors.primaryColor).copyWith(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: song.coverUrl.isNotEmpty
                        ? Image.network(
                            song.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    song.name,
                    style: AppTextStyles.subtitleMedium(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatArtists(song.artist),
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          song.album,
                          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDuration(song.duration),
                        style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  onPressed: onTagsPressed,
                  icon: const Icon(
                    Icons.local_offer,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.card,
                  onSelected: (String value) {
                    switch (value) {
                      case 'comments':
                        onCommentsPressed();
                        break;
                      case 'remove':
                        onRemovePressed();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'comments',
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.comment,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Comentários',
                            style: AppTextStyles.bodyMedium(),
                          ),
                        ],
                      ),
                    ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}