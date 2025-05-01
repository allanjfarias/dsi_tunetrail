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

  
  bool validarSenha(String tentativa) {
    return tentativa == _senha;
  }
}
