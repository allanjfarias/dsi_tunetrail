import 'package:flutter/material.dart';
import 'package:tunetrail/view/buscar_screen.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/song_repository.dart';

class TrendingArtistsScreen extends StatefulWidget {
  const TrendingArtistsScreen({super.key});

  @override
  State<TrendingArtistsScreen> createState() => _TrendingArtistsScreenState();
}

class _TrendingArtistsScreenState extends State<TrendingArtistsScreen> {
  final SongRepository _songRepository = SongRepository();
  late Future<List<String>> _trendingArtistsFuture;

  @override
  void initState() {
    super.initState();
    _trendingArtistsFuture = _songRepository.fetchTrendingArtists();
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
        title: Text('Artistas em Alta', style: AppTextStyles.headlineMedium()),
      ),
      body: FutureBuilder<List<String>>(
        future: _trendingArtistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar artistas: ${snapshot.error}',
                style: AppTextStyles.bodyMedium(color: AppColors.error),
              ),
            );
          }
          final List<String> artists = snapshot.data ?? [];
          if (artists.isEmpty) {
            return Center(
              child: Text(
                'Nenhum artista encontrado.',
                style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final String artist = artists[index];
              return ListTile(
                leading: const Icon(Icons.person, color: AppColors.primaryColor),
                title: Text(artist, style: AppTextStyles.subtitleMedium()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuscarScreen(
                        initialSearchQuery: artist,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}