import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
  }

class _BuscarScreenState extends State <BuscarScreen> {
  int _currentIndex = 1;
  // Exemplo de busca recente
  final List<String> recentSearches = <String>[
    'The Weeknd',
    'Pop Internacional',
    'Rock Classics',
    'Dua Lipa',
    'Indie 2024'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'lib/assets/tunetrail_banner.png', // Usei o banner pq não estava funcionando com o icon
                height: 60,
              ),
            ),
            Text(
              'Buscar',
              style: AppTextStyles.headlineLarge(
              ),
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
            const SizedBox(height: 30),
            Text(
              'Categorias populares',
              style: AppTextStyles.headlineSmall(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.0,
                children: <Widget>[
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
              style: AppTextStyles.headlineSmall(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(), // Efeito de bounce
                padding: EdgeInsets.zero,
                itemCount: recentSearches.length,
                itemBuilder: (BuildContext context,int index) {
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
        hintStyle: AppTextStyles.hintText(color: AppColors.primaryLight),
        prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
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

  Widget _buildCategoryItem(String title, IconData icon) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      // Adicionar as rotas
    },
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
        onTap: () {},
        
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