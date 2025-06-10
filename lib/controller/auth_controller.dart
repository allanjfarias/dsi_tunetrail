import '../models/user.dart' as local_user;
import '../models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import '../models/crud_repository.dart';

class AuthController {
  static final AuthController _instancia = AuthController._internal();
  final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  final CrudRepository<Profile> profileRepository = CrudRepository<Profile>(
    table: 'profiles',
    fromJson: Profile.fromJson,
    toJson: (Profile e) => e.toJson(),
  );
  final supa.SupabaseClient supaClient = supa.Supabase.instance.client;

  AuthController._internal();

  factory AuthController() {
    return _instancia;
  }

  local_user.User? _usuarioLogado;
  local_user.User? get usuarioLogado => _usuarioLogado;

  Future<bool> login(String email, String senha) async {
    try {
      final supa.GoTrueClient auth = supaClient.auth;
      final supa.AuthResponse response = await auth.signInWithPassword(
        email: email,
        password: senha,
      );

      final supa.User? sessionUser = response.user;

      if (sessionUser != null) {
        _usuarioLogado = local_user.User(
          id: sessionUser.id,
          email: sessionUser.email ?? '',
        );
        return true;
      }
      return false;
    } on supa.AuthException catch (authError) {
      throw Exception('Erro de autenticação: ${authError.message}');
    } catch (e, stack) {
      throw Exception('Erro ao fazer login: $e\nStack trace: $stack');
    }
  }

  Future<bool> registrar(
    String nome,
    String dataNasc,
    String genero,
    String email,
    String senha,
  ) async {
    final supa.GoTrueClient auth = supaClient.auth;

    try {
      final supa.AuthResponse response = await auth.signUp(
        email: email,
        password: senha,
      );

      final supa.User? newUser = response.user;
      if (newUser == null) return false;

      final Profile profile = Profile.fromStringDate(
        nome: nome,
        dataNasc: dataNasc,
        genero: genero,
        id: newUser.id,
      );

      await profileRepository.create(profile);

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

  void logout() async {
    final supa.GoTrueClient auth = supaClient.auth;
    _usuarioLogado = null;
    await auth.signOut();
  }

  Future<String?> enviarEmailRedefinicao(String email) async {
    final supa.GoTrueClient auth = supaClient.auth;
    try {
      await auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> redefinirSenhaComToken({
    required String recoveryToken,
    required String novaSenha,
    required String email,
  }) async {
    final supa.GoTrueClient auth = supaClient.auth;

    try {
      final supa.AuthResponse authResponse = await auth.verifyOTP(
        type: supa.OtpType.recovery,
        token: recoveryToken,
        email: email,
      );

      final supa.Session? session = authResponse.session;
      final supa.User? user = authResponse.user;

      if (session == null || user == null) {
        return 'Erro ao autenticar com token de recuperação.';
      }

      // 2. Atualiza a senha do usuário autenticado
      final supa.UserResponse updateResponse = await auth.updateUser(
        supa.UserAttributes(password: novaSenha),
      );

      if (updateResponse.user == null) {
        return 'Erro ao atualizar a senha.';
      }

      return null;
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }
}
