import '../models/user.dart' as local_user;
import '../models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      await supa.Supabase.instance.client.auth.resetPasswordForEmail(email);
      return null; // Sucesso, sem erro
    } catch (e) {
      return e.toString(); // Mensagem de erro para exibir
    }
  }

  /// Redefinir senha via recovery token enviado no e-mail (deep link)

  Future<String?> redefinirSenhaComToken({
    required String recoveryToken,
    required String novaSenha,
    required String email,
  }) async {
    final supa.SupabaseClient supabase = supa.Supabase.instance.client;

    debugPrint('[DEBUG] Iniciando redefinição de senha via verifyOTP');
    debugPrint('[DEBUG] Token: $recoveryToken');
    debugPrint('[DEBUG] Nova senha: $novaSenha');

    try {
      // 1. Verifica o token de recuperação e inicia a sessão
      final supa.AuthResponse authResponse = await supabase.auth.verifyOTP(
        type: supa.OtpType.recovery,
        token: recoveryToken,
        email: email
      );

      final supa.Session? session = authResponse.session;
      final supa.User? user = authResponse.user;

      if (session == null || user == null) {
        debugPrint('[DEBUG] Sessão ou usuário inválido após verifyOTP');
        return 'Erro ao autenticar com token de recuperação.';
      }

      debugPrint('[DEBUG] Sessão iniciada com sucesso');
      debugPrint('[DEBUG] Atualizando senha...');

      // 2. Atualiza a senha do usuário autenticado
      final supa.UserResponse updateResponse = await supabase.auth.updateUser(
        supa.UserAttributes(password: novaSenha),
      );

      if (updateResponse.user == null) {
        debugPrint('[DEBUG] Erro ao atualizar senha');
        return 'Erro ao atualizar a senha.';
      }

      debugPrint('[DEBUG] Senha atualizada com sucesso');
      return null; // Sucesso
    } catch (e) {
      debugPrint('[DEBUG] Erro durante redefinição: $e');
      return 'Erro inesperado: $e';
    }
  }
}
