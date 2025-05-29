import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
  }

class _BuscarScreenState extends State <BuscarScreen> {
  int _currentIndex = 1;
  // Exemplo de busca recente
  final List<String> recentSearches = [
    'The Weeknd',
    'Pop Internacional',
    'Rock Classics',
    'Dua Lipa',
    'Indie 2024'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'lib/assets/tunetrail_banner.png', // Usei o banner pq não estava funcionando com o icon
                height: 60,
              ),
            ),
            Text(
              'Buscar',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 30),
            Text(
              'Categorias populares',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.0,
                children: [
                  _buildCategoryItem('Artistas em alta', Icons.people_alt_rounded),
                  _buildCategoryItem('Músicas em alta', Icons.trending_up_rounded),
                  _buildCategoryItem('Novos lançamentos', Icons.new_releases_rounded),
                  _buildCategoryItem('Gêneros musicais', Icons.music_note_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recentes',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(), // Efeito de bounce
                padding: EdgeInsets.zero,
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRecentSearchItem(recentSearches[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0XFF202022),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF34B3F1),
        unselectedItemColor: Colors.grey,
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
              Navigator.pushReplacementNamed(context, '/buscar_screen');
              break;
          }
        },
      ),
    );
  }


  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'O que você procura?',
        hintStyle: const TextStyle(color: Colors.blueAccent),
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.blueAccent,
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      // Adicionar as rotas
    },
    child: Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.7),
            Colors.purpleAccent.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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
        onTap: () {},
        
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, size: 20, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  searchTerm,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16, 
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

}