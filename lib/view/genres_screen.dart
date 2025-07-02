import 'package:flutter/material.dart';
import 'package:tunetrail/view/genre_songs_screen.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/song_repository.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  final SongRepository _songRepository = SongRepository();
  late Future<List<String>> _genresFuture;

  @override
  void initState() {
    super.initState();
    _genresFuture = _songRepository.fetchUniqueGenres();
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
        title: Text('Gêneros Musicais', style: AppTextStyles.headlineMedium()),
      ),
      body: FutureBuilder<List<String>>(
        future: _genresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar gêneros: ${snapshot.error}', style: AppTextStyles.bodyMedium(color: AppColors.error)));
          }
          final List<String> genres = snapshot.data ?? [];
          if (genres.isEmpty) {
            return Center(child: Text('Nenhum gênero encontrado.', style: AppTextStyles.bodyLarge(color: AppColors.textSecondary)));
          }
          return ListView.separated(
            itemCount: genres.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 1),
            itemBuilder: (context, index) {
              final String genre = genres[index];
              return ListTile(
                title: Text(genre, style: AppTextStyles.subtitleMedium()),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  // Navega para a tela que mostra as músicas do gênero selecionado
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenreSongsScreen(genre: genre),
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