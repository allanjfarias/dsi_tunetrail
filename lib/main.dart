import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'view/redef_senha_nova_senha.dart';
import 'view/login.dart';
import 'view/home_screen.dart';

// Declarar globalmente a chave do Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: const EmptyLocalStorage(),
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

    // Escuta links quando o app está aberto (foreground)
    _appLinks.uriLinkStream.listen((Uri uri) => _handleDeepLink(uri));
  }

  Future<void> _handleDeepLink(Uri? uri) async {
    if (uri == null) return;

    if (uri.host != 'reset-password') {
      return;
    }

    final String? recoveryCode = uri.queryParameters['code'];
    if (recoveryCode == null || recoveryCode.isEmpty) {
      return;
    }

    // Navegar usando navigatorKey para garantir contexto válido
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AlterarSenhaScreen(recoveryCode: recoveryCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneTrail',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: InitialScreen(handleDeepLink: _handleDeepLink),
    );
  }
}

class InitialScreen extends StatefulWidget {
  final Future<void> Function(Uri?) handleDeepLink;

  const InitialScreen({super.key, required this.handleDeepLink});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _checkDeepLinkAndNavigate();
  }

  Future<void> _checkDeepLinkAndNavigate() async {
    final Uri? uri = await _appLinks.getInitialLink();
    if (uri != null) {
      await widget.handleDeepLink(uri);
      return; // Navegou via deep link
    }

    // Se não veio por deep link, verifica login
    final User? user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Usuário logado, vai para Home
      if (!mounted) return;
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } else {
      // Usuário não logado, vai para Login
      if (!mounted) return;
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Iniciando...')));
  }
}
