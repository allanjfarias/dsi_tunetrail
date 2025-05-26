import '../models/user.dart' as local_user;
import '../models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthController {
  static final AuthController _instancia = AuthController._internal();
  final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  AuthController._internal();

  factory AuthController() {
    return _instancia;
  }

  local_user.User? _usuarioLogado;
  local_user.User? get usuarioLogado => _usuarioLogado;

  /// Login com Supabase Auth
  Future<bool> login(String email, String senha) async {
    debugPrint('[DEBUG] Iniciando login para $email');

    try {
      final supa.AuthResponse res = await supa.Supabase.instance.client.auth
          .signInWithPassword(email: email, password: senha);

      final supa.User? sessionUser = res.user;
      debugPrint('[DEBUG] Resposta Auth: user=${sessionUser?.email}');

      if (sessionUser != null) {
        _usuarioLogado = local_user.User(
          id: sessionUser.id,
          email: sessionUser.email ?? '',
        );
        debugPrint('[DEBUG] Login bem-sucedido para ${_usuarioLogado!.email}');
        return true;
      }

      debugPrint('[DEBUG] Login falhou: usuário nulo');
      return false;
    } on supa.AuthException catch (authError) {
      debugPrint('[DEBUG] AuthException: ${authError.message}');
      return false;
    } catch (e, stack) {
      debugPrint('[DEBUG] Erro inesperado no login: $e');
      debugPrint('[DEBUG] StackTrace: $stack');
      return false;
    }
  }

  /// Registro no Supabase (Auth + tabela profile)
  Future<bool> registrar(
    String nome,
    String dataNasc,
    String genero,
    String email,
    String senha,
  ) async {
    try {
      final supa.AuthResponse res = await supa.Supabase.instance.client.auth
          .signUp(email: email, password: senha);

      final supa.User? newUser = res.user;
      if (newUser == null) return false;

      // Salva os dados do perfil na tabela 'profiles'
      final Profile profile = Profile.fromStringDate(
        nome: nome,
        dataNascString: dataNasc,
        genero: genero,
      );

      await supa.Supabase.instance.client.from('profiles').insert(
        <String, dynamic>{'id': newUser.id, ...profile.toMap()},
      );

      _usuarioLogado = local_user.User(
        id: newUser.id,
        email: newUser.email ?? '',
      );
      return true;
    } catch (e) {
      debugPrint('Erro ao registrar: $e');
      return false;
    }
  }

  void logout() {
    _usuarioLogado = null;
  }

  Future<String?> enviarEmailRedefinicao(String email) async {
    try {
      await supa.Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'https://allanjfarias.github.io/tunetrail-redirect/', // Ajuste seu deep link real aqui
      );
      return null; // Sucesso, sem erro
    } catch (e) {
      return e.toString(); // Mensagem de erro para exibir
    }
  }

  /// Redefinir senha via recovery token enviado no e-mail (deep link)

  Future<String?> redefinirSenhaComToken({
    required String recoveryToken,
    required String novaSenha,
  }) async {
    final String supabaseUrl = this.supabaseUrl;

    final Uri url = Uri.parse('$supabaseUrl/auth/v1/verify');

    debugPrint('[DEBUG] Iniciando redefinição de senha');
    debugPrint('[DEBUG] URL de redefinição: $url');
    debugPrint('[DEBUG] Recovery Token: $recoveryToken');
    debugPrint('[DEBUG] Novo senha: $novaSenha');

    try {
      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      };
      final Map<String, String> body = <String, String>{
        'type': 'recovery',
        'token': recoveryToken,
        'password': novaSenha,
      };

      debugPrint('[DEBUG] Headers: $headers');
      debugPrint('[DEBUG] Body: ${jsonEncode(body)}');

      final http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('[DEBUG] Status Code: ${response.statusCode}');
      debugPrint('[DEBUG] Resposta do servidor: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('[DEBUG] Redefinição de senha bem-sucedida');
        return null; // Sucesso
      } else {
        debugPrint('[DEBUG] Erro na redefinição de senha');
        return 'Erro ao redefinir senha: ${response.body}';
      }
    } catch (e) {
      debugPrint('[DEBUG] Exceção inesperada: $e');
      return 'Erro inesperado: $e';
    }
  }
}
