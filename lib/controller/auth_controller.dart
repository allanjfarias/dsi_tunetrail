import '../models/user.dart';

class AuthController {
  final List<User> _usuarios = <User>[];

  User? _usuarioLogado;

  User? get usuarioLogado => _usuarioLogado;

  bool login(String identificador, String senha) {
    for (User user in _usuarios) {
      if (identificador == user.email || identificador == user.username) {
        return user.validarSenha(senha);
      }
    }
    return false;
  }

  bool registro(String email, String username, String senha) {  
    
    for (User user in _usuarios) {
      if (user.email == email || user.username == username) {
        return false;
      }
    }

    final User novoUsuario = User(
      email: email,
      username: username,
      senha: senha,
    );

    _usuarios.add(novoUsuario);
    _usuarioLogado = novoUsuario;
    return true;
  }

  void logout() {
    _usuarioLogado = null;
  }
}
