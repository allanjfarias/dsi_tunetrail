class User {
  final String _email;
  final String _username;
  final String _senha;

  User({required String email, required String username, required String senha})
    : _email = email,
      _username = username,
      _senha = senha;

  String get email => _email;
  String get username => _username;

  bool validarLogin(String identificador, String senha) {
    final bool loginPorEmailCorreto =
        identificador == _email && senha == _senha;
    final bool loginPorUsernameCorreto =
        identificador == _username && senha == _senha;

    return loginPorEmailCorreto || loginPorUsernameCorreto;
  }
}
