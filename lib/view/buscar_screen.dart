import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/song.dart';
import '../models/song_repository.dart';
import '../controller/search_history_controller.dart';

class BuscarScreen extends StatefulWidget {
  final bool selectMode;
  final String? initialSearchQuery;
  
  const BuscarScreen({super.key, this.selectMode = false, this.initialSearchQuery,});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = <Song>[];
  bool _isSearching = false;
  bool _isLoading = false;
  final SongRepository _songRepository = SongRepository();
  final SearchHistoryController _historyController = SearchHistoryController();
  List<String> _recentSearches = <String>[];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocusNode.addListener(_onSearchFocusChange);
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.text = widget.initialSearchQuery!;
        _fetchSearchResults(widget.initialSearchQuery!);
      });
    } else if (widget.selectMode) {
      _loadPopularSongs();
    }
  }

  Future<void> _loadRecentSearches() async {
    final List<String> history = await _historyController.getSearchHistory();
    if (mounted) {
      setState(() {
        _recentSearches = history;
      });
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = <Song>[];
        _isSearching = false;
      });
      if (widget.selectMode) {
        _loadPopularSongs();
      }
      return;
    }
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });
    try {
      final List<Song> results = await _songRepository.searchSongs(trimmedQuery);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar músicas: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPopularSongs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Song> popularSongs = await _songRepository.fetchPopularSongs();
      if (!mounted) return;
      setState(() {
        _searchResults = popularSongs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar músicas populares: $e')),
      );
    } finally {
      if (!mounted) {}
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveSearchToHistory(String query) async {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      await _historyController.addSearchTerm(trimmedQuery);
      _loadRecentSearches();
    }
  }

  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      _saveSearchToHistory(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectSong(Song song) {
    if (widget.selectMode) {
      Navigator.pop(context, song);
    }
  }

  String _formatDuration(double durationMs) {
    if (durationMs == 0) return '0:00';
    final int totalSeconds = (durationMs / 1000).round();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.selectMode
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!widget.selectMode)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.asset(
                  'lib/assets/tunetrail_banner.png',
                  height: 60,
                ),
              ),
            Text(
              widget.selectMode ? 'Selecionar música' : 'Buscar',
              style: AppTextStyles.headlineLarge(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSearchBar(),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : (_isSearching && _searchResults.isNotEmpty) || widget.selectMode && _searchResults.isNotEmpty
                    ? Expanded(child: _buildSearchResults())
                    : (_isSearching && _searchResults.isEmpty) || widget.selectMode && _searchResults.isEmpty
                        ? Expanded(child: _buildNoResults())
                        : Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Categorias populares',
                                  style: AppTextStyles.headlineSmall(),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  flex: 2,
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 2.0,
                                    children: <Widget>[
                                      _buildCategoryItem(
                                        'Artistas em alta',
                                         Icons.people_alt_rounded,
                                         onTap: () {
                                          Navigator.pushNamed(context, '/trending_artists').then((_) {
                                            _loadRecentSearches();
                                          });
                                         }
                                      ),
                                      _buildCategoryItem(
                                        'Músicas em alta',
                                         Icons.trending_up_rounded,
                                         onTap: () {
                                          Navigator.pushNamed(context, '/trending_songs');
                                         }
                                      ),
                                      _buildCategoryItem(
                                        'Novos lançamentos',
                                         Icons.new_releases_rounded,
                                         onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Em breve: Novos Lançamentos!',
                                                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
                                              ),
                                              backgroundColor: AppColors.primaryColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                         }
                                      ),
                                      _buildCategoryItem(
                                        'Gêneros musicais',
                                         Icons.music_note_rounded,
                                         onTap: () {
                                          Navigator.pushNamed(context, '/genres');
                                         }
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Recentes',
                                  style: AppTextStyles.headlineSmall(),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: _recentSearches.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildRecentSearchItem(_recentSearches[index]),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
          ],
        ),
      ),
      bottomNavigationBar: widget.selectMode
          ? null
          : BottomNavigationBar(
              backgroundColor: AppColors.background,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: AppColors.textDisabled,
              currentIndex: 1,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Eventos'),
              ],
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/home_screen');
                    break;
                  case 1:
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/profile');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/eventos_screen');
                    break;
                }
              },
            ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: _fetchSearchResults,
      onSubmitted: _saveSearchToHistory,
      decoration: InputDecoration(
        hintText: widget.selectMode ? 'Buscar músicas...' : 'O que você procura?',
        hintStyle: AppTextStyles.hintText(color: AppColors.primaryLight),
        prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  _fetchSearchResults('');
                },
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              )
            : null,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      style: AppTextStyles.inputText(),
      cursorColor: AppColors.primaryColor,
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (BuildContext context, int index) {
        final Song song = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildSongCard(song),
        );
      },
    );
  }

  Widget _buildPopularSongs() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (BuildContext context, int index) {
        final Song song = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildSongCard(song),
        );
      },
    );
  }

  Widget _buildSongCard(Song song) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[AppColors.cardShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: song.coverUrl.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(song.coverUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: song.coverUrl.isEmpty
              ? const Icon(
                  Icons.music_note,
                  color: AppColors.textPrimary,
                  size: 24,
                )
              : null,
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
              song.artist.replaceAll(';', ', '),
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                if (song.explicit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'E',
                      style: AppTextStyles.bodyMedium().copyWith(fontSize: 10),
                    ),
                  ),
                if (song.explicit) const SizedBox(width: 8),
                Text(
                  song.genre,
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
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
        trailing: widget.selectMode
            ? IconButton(
                onPressed: () => _selectSong(song),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              )
            : null,
        onTap: widget.selectMode ? () => _selectSong(song) : null,
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum resultado encontrado',
            style: AppTextStyles.headlineSmall(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar por outro termo',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[AppColors.cardShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 28, color: AppColors.icon),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitleMedium(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String searchTerm) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _searchController.text = searchTerm;
        _fetchSearchResults(searchTerm);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.history, size: 20, color: AppColors.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                searchTerm,
                style: AppTextStyles.bodyLarge(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}