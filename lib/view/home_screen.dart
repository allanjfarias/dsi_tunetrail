import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            Icon(Icons.music_note, color: theme.colorScheme.primary),
            const SizedBox(width: 2),
            Text(
              'TuneTrail',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _buildSectionTitle(context, 'Eventos próximos'),
          const SizedBox(height: 12),
          _buildHorizontalCardList(
            context,
            items: _eventosData,
            cardType: CardType.eventos,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Suas playlists'),
          const SizedBox(height: 12),
          _buildHorizontalCardList(
            context,
            items: _playlistsData,
            cardType: CardType.playlists,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Novidades'),
          const SizedBox(height: 12),
          _buildHorizontalCardList(
            context,
            items: _novidadesData,
            cardType: CardType.novidades,
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
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
          // TODO: navegação
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final ThemeData theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHorizontalCardList(
    BuildContext context, {
    required List<Map<String, String>> items,
    required CardType cardType,
  }) {
    final ThemeData theme = Theme.of(context);
    const double cardHeight = 120;
    const double cardWidth = 120;
    const double textSpaceHeight = 55;

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
            padding: const EdgeInsets.only(right: 12),
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
                              ? theme.colorScheme.primary
                              : const Color(0xff181818),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          cardType != CardType.eventos
                              ? Border.all(
                                color: const Color(0xff303131),
                                width: 1,
                              )
                              : null,
                    ),
                    child:
                        cardType == CardType.eventos
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  item['title'] ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            : Image.asset(
                              item['image'] ?? '',
                              fit: BoxFit.cover,
                            ),
                  ),
                  if (cardType != CardType.eventos)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        item['title'] ?? 'Nome ${index + 1}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
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
