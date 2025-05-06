import '../models/user.dart';
import '../dao/user_dao.dart';

class AuthController {
  static final AuthController _instancia = AuthController._internal();

  AuthController._internal();

  factory AuthController() {
    return _instancia;
  }

  final UserDao _userDao = UserDao();
  User? _usuarioLogado;

  User? get usuarioLogado => _usuarioLogado;

  bool login(String identificador, String senha) {
    for (User user in _userDao.listar) {
      if (identificador == user.email) {
        return user.validarSenha(senha);
      }
    }
    return false;
  }

  bool registrar(
    String nome,
    String dataNasc,
    String genero,
    String email,
    String senha,
  ) {
    final User novoUsuario = User(
      nome: nome,
      dataNasc: dataNasc,
      genero: genero,
      email: email,
      senha: senha,
    );
    bool cadastrou = _userDao.cadastrar(novoUsuario);
    if (cadastrou) {
      _usuarioLogado = novoUsuario;
    }
    return cadastrou;
  }

  void logout() {
    _usuarioLogado = null;
  }
}
