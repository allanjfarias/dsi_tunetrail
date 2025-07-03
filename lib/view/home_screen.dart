import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tunetrail/controller/auth_controller.dart';
import 'package:tunetrail/models/profile.dart';
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
  Profile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authController.usuarioLogado;
    if (user != null) {
      try {
        final profile = await _authController.profileRepository.readOne(user.id);
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  // dados de exemplo para os carrosséis
  static const List<Map<String, String>> _eventosData = <Map<String, String>>[
  <String, String>{'title': 'Show de Rock em Recife','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Festival Jazz & Blues','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Orquestra Sinfônica','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Samba na Lapa','image': 'https://i.imgur.com/btItlKy.jpeg',},
];

static const List<Map<String, String>> _playlistsData = <Map<String, String>>[
  <String, String>{'title': 'Top Hits Brasil','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Festa de Aniversário','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Sons da Natureza','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Treino Pesado','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Eletrônica Pura','image': 'https://i.imgur.com/btItlKy.jpeg',},
];

static const List<Map<String, String>> _novidadesData = <Map<String, String>>[
  <String, String>{'title': 'Novo álbum: After Hours','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Single: Blinding Lights','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'EP: My Dear Melancholy','image': 'https://i.imgur.com/btItlKy.jpeg',},
  <String, String>{'title': 'Novo remix de X','image': 'https://i.imgur.com/btItlKy.jpeg',},
];

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
            Text(
              'TuneTrail',
              style: AppTextStyles.headlineLarge(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)) 
          :ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Text(
                'Olá,',
                style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
              ),
              Text(
                _userProfile?.nome ?? 'Usuário',
                style: AppTextStyles.headlineMedium(),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Eventos próximos'),
              const SizedBox(height: 12),
              _buildHorizontalCardList(items: _eventosData,),
              const SizedBox(height: 24),
              _buildSectionTitle('Suas playlists'),
              const SizedBox(height: 12),
              _buildHorizontalCardList(items: _playlistsData),
              const SizedBox(height: 24),
              _buildSectionTitle('Novidades'),
              const SizedBox(height: 12),
              _buildHorizontalCardList(items: _novidadesData),
              const SizedBox(height: 24),
            ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Eventos',
          ),
        ],
        onTap: (int index) {
          setState(() {
          });
          switch (index) {
            case 0:
              break;
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineSmall(),
    );
  }

  Widget _buildHorizontalCardList({
    required List<Map<String, String>> items,
  }) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, String> item = items[index];
          return HomeCard(
            title: item['title'] ?? '',
            imageUrl: item['image'] ?? 'https://via.placeholder.com/150',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clicou em ${item['title']}')),
              );
            },
          );
        },
      ),
    );
  }
}
