import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  }

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  

  // dados de exemplo para os carrosséis
  static const List<Map<String, String>> _eventosData = <Map<String, String>>[
    <String, String>{
      'title': 'Show de rock em Recife',
      'image': 'assets/images/evento1.png',
    },
    <String, String>{
      'title': 'Festival Jazz & Blues',
      'image': 'assets/images/evento2.png',
    },
    <String, String>{
      'title': 'Orquestra Sinfônica',
      'image': 'assets/images/evento3.png',
    },
    <String, String>{
      'title': 'Samba na lapa',
      'image': 'assets/images/evento5.png',
    },
    <String, String>{
      'title': 'Show de sertanejo universitário',
      'image': 'assets/images/evento6.png',
    },
  ];

  static const List<Map<String, String>> _playlistsData = <Map<String, String>>[
    <String, String>{
      'title': 'Top Hits Brasil',
      'image': 'assets/images/playlist1.png',
    },
    <String, String>{
      'title': 'Festa de aniversário',
      'image': 'assets/images/playlist2.png',
    },
    <String, String>{
      'title': 'Sons da natureza',
      'image': 'assets/images/playlist3.png',
    },
    <String, String>{
      'title': 'Treino Pesado',
      'image': 'assets/images/playlist4.png',
    },
    <String, String>{
      'title': 'Clássicos Inesquecíveis',
      'image': 'assets/images/playlist6.png',
    },
    <String, String>{
      'title': 'Eletrônica Pura',
      'image': 'assets/images/playlist7.png',
    },
  ];

  static const List<Map<String, String>> _novidadesData = <Map<String, String>>[
    <String, String>{
      'title': 'Novo álbum: xxx de xxx',
      'image': 'assets/images/novidade1.png',
    },
    <String, String>{
      'title': 'Novo single de X',
      'image': 'assets/images/novidade2.png',
    },
    <String, String>{
      'title': 'Novo EP de X',
      'image': 'assets/images/novidade3.png',
    },
    <String, String>{
      'title': 'Novo álbum ao vivo',
      'image': 'assets/images/novidade4.png',
    },
    <String, String>{
      'title': 'Novo remix de X',
      'image': 'assets/images/novidade5.png',
    },
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
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSectionTitle('Eventos próximos'),
          const SizedBox(height: 12),
          _buildHorizontalCardList(
            items: _eventosData,
            cardType: CardType.eventos,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Suas playlists'),
          const SizedBox(height: 12),
          _buildHorizontalCardList(
            items: _playlistsData,
            cardType: CardType.playlists,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Novidades'),
          const SizedBox(height: 12),
          _buildHorizontalCardList(
            items: _novidadesData,
            cardType: CardType.novidades,
          ),
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
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home_screen');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/buscar_screen');
              break;
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHorizontalCardList({
    required List<Map<String, String>> items,
    required CardType cardType,
  }) {
    double cardHeight = 120;
    double cardWidth = 120;
    double textSpaceHeight =
        55; // altura necessária pra o texto abaixo dos cards

    return SizedBox(
      height:
          cardType == CardType.eventos
              ? cardHeight
              : cardHeight + textSpaceHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, String> item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: cardWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color:
                          cardType == CardType.eventos
                              ? AppColors.primaryColor
                              : AppColors.card,
                      borderRadius: BorderRadius.circular(8.0),
                      border:
                          cardType != CardType.eventos
                              ? Border.all(
                                color: AppColors.divider,
                                width: 1,
                              )
                              : null,
                    ),
                    child: Center(
                      child:
                          cardType == CardType.eventos
                              ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  item['title'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                              : null,
                    ),
                  ),
                  if (cardType != CardType.eventos)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        item['title'] ?? 'Nome ${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum CardType { eventos, playlists, novidades }
