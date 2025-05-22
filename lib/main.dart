import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'view/login.dart';
import 'view/redef_senha_nova_senha.dart'; // tela para alterar a senha

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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
    _initAppLinks();
  }

  void _initAppLinks() {
    _appLinks = AppLinks();

    // Escuta links enquanto o app está aberto
    _appLinks.uriLinkStream.listen(_handleIncomingLink, onError: (dynamic err) {
      debugPrint('Erro ao escutar link: $err');
    });

    // Verifica se o app foi aberto pelo link
    _appLinks.getInitialLink().then(_handleIncomingLink).catchError((dynamic err) {
      debugPrint('Erro ao obter link inicial: $err');
    });
  }

  void _handleIncomingLink(Uri? uri) {
  if (uri == null) return;

  debugPrint('Deep link recebido: $uri');

  if (uri.path == '/reset-password') {
    final String fragment = uri.fragment; // access_token=xyz&type=recovery

    if (fragment.isEmpty) {
      debugPrint('Fragmento vazio no link.');
      return;
    }

    final Map<String, String> params = Uri.splitQueryString(fragment);

    final String? accessToken = params['access_token'];
    final String? type = params['type'];

    if (type == 'recovery' && accessToken != null && accessToken.isNotEmpty) {
      debugPrint('Token recebido: $accessToken');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AlterarSenhaScreen(accessToken: accessToken),
        ),
      );
    } else {
      debugPrint('Link de redefinição inválido ou sem token.');
    }
  } else {
    debugPrint('Deep link não corresponde a /reset-password. Caminho: ${uri.path}');
  }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneTrail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LoginScreen(),
    );
  }
}
