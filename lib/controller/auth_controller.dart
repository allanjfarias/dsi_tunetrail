import '../models/user.dart';

class AuthController {
  final List<User> _usuarios = <User>[];
  User? _usuarioLogado;


  User? get usuarioLogado => _usuarioLogado;


  bool login(String identificador, String senha) {
    for (User user in _usuarios) {
      if (user.validarLogin(identificador, senha)) {
        _usuarioLogado = user;
        return true;
      }
    }
    return false;
  }

  bool registrar(String email, String username, String senha) {   
    bool existe = _usuarios.any(
      (User u) => u.email == email || u.username == username,
    );

    if (existe) return false;

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
