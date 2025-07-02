import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'view/buscar_screen.dart';
import 'view/home_screen.dart';
import 'view/profile_screen.dart';
import 'view/edit_profile_screen.dart';
import 'view/events_screen.dart';
import 'view/my_playlists_screen.dart';
import 'view/create_playlist_screen.dart';
import 'view/redef_senha_nova_senha.dart';
import 'view/login.dart';
import 'view/trending_artists_screen.dart';

// Declarar globalmente a chave do Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClientOptions(
      localStorage: const EmptyLocalStorage(), // Sem persistência
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((Uri uri) {
     
      if (uri.host != 'reset-password') return;

      final String? recoveryCode = uri.queryParameters['access_token'];
      if (recoveryCode == null || recoveryCode.isEmpty) return;

      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute<dynamic>(
          builder: (_) => AlterarSenhaScreen(recoveryCode: recoveryCode),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TuneTrail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // Começa direto na tela de login
      home: const LoginScreen(),
      routes:<String, Widget Function(BuildContext)> {
        '/home_screen': (BuildContext context) => const HomeScreen(),
        '/buscar_screen': (BuildContext context) => const BuscarScreen(),
        '/eventos_screen': (BuildContext context) => const  MapEventScreen(),
        '/profile': (BuildContext context) => const ProfileScreen(),
        '/edit_profile': (BuildContext context) => const EditProfileScreen(),
        '/my_playlists': (BuildContext context) => const MyPlaylistsScreen(),
        '/create_playlist': (BuildContext context) => const CreatePlaylistScreen(),
        '/login': (BuildContext context) => const LoginScreen(),   
        '/trending_artists': (BuildContext context) => const TrendingArtistsScreen(),     
      },
      onUnknownRoute: (RouteSettings settings) =>  MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: Center(child: Text('Rota ${settings.name} não encontrada')),
        ),
      ),
    );
  }
}