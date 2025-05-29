import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tunetrail/view/buscar_screen.dart';
import 'package:tunetrail/view/home_screen.dart';
import 'view/redef_senha_nova_senha.dart';
import 'view/login.dart';


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
      routes: {
        '/home_screen': (BuildContext context) => const HomeScreen(),
        '/buscar_screen': (BuildContext context) => const BuscarScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Rota ${settings.name} não encontrada')),
        ),
      ),
    );
  }
}
