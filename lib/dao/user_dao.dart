import '../models/user.dart';

class UserDao {
  static final UserDao _instancia = UserDao._internal();

  UserDao._internal();

  factory UserDao() {
    return _instancia;
  }

  final List<User> _usuarios = <User>[];

  bool cadastrar(User novoUsuario) {
    bool existe = _usuarios.any(
      (User u) =>
          u.email == novoUsuario.email);

    if (existe) return false;

    _usuarios.add(novoUsuario);
    return true;
  }

  List<User> get listar => List<User>.from(_usuarios);

  bool email_cadastrado(String email) {
    return _usuarios.any((User usuario) => usuario.email == email);
  }

  bool alterarSenha(String emailUsuario, String novaSenha) {
    try {
      User usuario = _usuarios.firstWhere((User usuario) => usuario.email == emailUsuario);
      usuario.alterarSenha(novaSenha);
      return true;
    } catch (e) {
      return false; // Retorna false se o usuário não for encontrado
    }
  }
}
