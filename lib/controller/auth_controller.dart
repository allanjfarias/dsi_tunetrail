import '../models/user.dart' as local_user;
import '../models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AuthController {
  static final AuthController _instancia = AuthController._internal();
  final String supabaseUrl = dotenv.env['SUPABASE_URL']!; 


  AuthController._internal();

  factory AuthController() {
    return _instancia;
  }

  local_user.User? _usuarioLogado;
  local_user.User? get usuarioLogado => _usuarioLogado;

  /// Login com Supabase Auth
  Future<bool> login(String email, String senha) async {
    try {
      final supa.AuthResponse res = await supa.Supabase.instance.client.auth
          .signInWithPassword(email: email, password: senha);

      final supa.User? sessionUser = res.user;
      if (sessionUser != null) {
        _usuarioLogado = local_user.User(
          id: sessionUser.id,
          email: sessionUser.email ?? '',
        );
        return true;
      }

      return false;
    } catch (e) {
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
        redirectTo: 'tunetrail://reset-password',
        
        // Opcional: configure seu deep link aqui se usar
        // redirectTo: 'yourapp://reset-password',
      );
      return null; // Sucesso, sem erro
    } catch (e) {
      return e.toString(); // Mensagem de erro para exibir
    }
  }

  Future<bool> alterarSenhaComToken({
    required String novaSenha,
    required String accessToken,
  }) async {
    final Uri url = Uri.parse('${supabaseUrl.replaceAll(RegExp(r'/+$'), '')}/auth/v1/user');


    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, String> {'password': novaSenha}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
