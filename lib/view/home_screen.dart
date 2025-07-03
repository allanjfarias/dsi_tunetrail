import 'package:flutter/material.dart';
import 'package:tunetrail/controller/auth_controller.dart';
import 'package:tunetrail/controller/event_controller.dart';
import 'package:tunetrail/models/event.dart';
import 'package:tunetrail/models/event_repository.dart';
import 'package:tunetrail/models/profile.dart';
import 'package:tunetrail/view/dialogs/event_details_popup.dart';
import 'package:tunetrail/models/playlist_repository.dart';
import 'package:tunetrail/models/playlist.dart';
import 'package:tunetrail/view/playlist_details_screen.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import 'home/home_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = AuthController();
  final EventRepository _eventRepository = EventRepository();
  final EventController _eventController = EventController();
  final PlaylistRepository _playlistRepository = PlaylistRepository();
  late Future<Profile?> _userProfileFuture;
  late Future<List<Event>> _eventsFuture;
  late Future<List<Playlist>> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = _authController.usuarioLogado;
    _userProfileFuture = (user != null) ? _authController.profileRepository.readOne(user.id) : Future.value(null);
    _eventsFuture = _eventRepository.fetchAllEvents();
    if (user != null) {
      _playlistsFuture = _playlistRepository.fetchUserPlaylists(user.id);
    } else {
      _playlistsFuture = Future.value([]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: <Widget>[
            const Icon(Icons.music_note, color: AppColors.primaryColor),
            const SizedBox(width: 2),
            Text('TuneTrail', style: AppTextStyles.headlineLarge(color: AppColors.primaryColor)),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.primaryColor,
        backgroundColor: AppColors.card,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildGreeting(),
            const SizedBox(height: 24),

            _buildSectionTitle('Eventos'),
            const SizedBox(height: 12),
            _buildEventsCarousel(),
            const SizedBox(height: 24),
            _buildSectionTitle('Suas Playlists'),
            const SizedBox(height: 12),
            _buildPlaylistsCarousel(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textDisabled,
        currentIndex: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Eventos'),
        ],
        onTap: (int index) {
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/buscar_screen');
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

  Widget _buildGreeting() {
    return FutureBuilder<Profile?>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const SizedBox(height: 48);
        }
        final String name = snapshot.data?.nome ?? 'Usuário';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá,', style: AppTextStyles.bodyLarge(color: AppColors.textSecondary)),
            Text(name, style: AppTextStyles.headlineMedium()),
          ],
        );
      },
    );
  }

  Widget _buildEventsCarousel() {
    return FutureBuilder<List<Event>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        if (snapshot.hasError) {
          return _buildEmptyState('Erro ao carregar eventos.');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Nenhum evento encontrado.');
        }

        final List<Event> events = snapshot.data!;
        return _buildHorizontalCardList(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final Event event = events[index];
            return HomeCard(
              title: event.name,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => EventDetailsPopup(
                    event: event,
                    eventController: _eventController,
                    authController: _authController,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHorizontalCardList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: AppTextStyles.headlineSmall());

  Widget _buildLoadingIndicator() => const SizedBox(
      height: 140, child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)));

  Widget _buildEmptyState(String message) => SizedBox(
      height: 140, child: Center(child: Text(message, style: AppTextStyles.bodyMedium(color: AppColors.textSecondary))));
  
  Widget _buildPlaylistsCarousel() {
  return FutureBuilder<List<Playlist>>(
    future: _playlistsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingIndicator();
      }
      if (snapshot.hasError) {
        return _buildEmptyState('Erro ao carregar playlists.');
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildEmptyState('Ainda não possui playlists');
      }
      final List<Playlist> playlists = snapshot.data!;
      return _buildHorizontalCardList(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final Playlist playlist = playlists[index];
          return HomeCard(
            title: playlist.title,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailsScreen(playlist: playlist),
                ),
              );
            },
          );
        },
      );
    },
  );
}

}
