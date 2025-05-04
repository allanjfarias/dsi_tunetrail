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
          u.email == novoUsuario.email || u.username == novoUsuario.username,
    );

    if (existe) return false;

    _usuarios.add(novoUsuario);
    return true;
  }

  List<User> get listar => List<User>.from(_usuarios);
}
