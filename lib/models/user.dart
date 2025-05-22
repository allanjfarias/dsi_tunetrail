import 'package:intl/intl.dart';

class User {
  String _nome;
  DateTime _dataNasc;
  String _genero;
  final String _email;
  String _senha;

  User({
    required String nome,
    required String dataNasc,
    required String genero,
    required String email,
    required String senha,
  }) : _nome = nome,
       _dataNasc = DateFormat('dd/MM/yyyy').parse(dataNasc),
       _genero = genero,
       _email = email,
       _senha = senha;

  String get nome => _nome;
  DateTime get dataNasc => _dataNasc;
  int get idade => _calcularIdade(dataNasc);
  String get genero => _genero;
  String get email => _email;

  bool validarSenha(String tentativa) {
    return tentativa == _senha;
  }

  void alterarSenha(String novaSenha) {
    _senha = novaSenha;
  }

  // Função para calcular a idade
  int _calcularIdade(DateTime dataNasc) {
    DateTime hoje = DateTime.now();
    int idade = hoje.year - dataNasc.year;
    if (hoje.month < dataNasc.month ||
        (hoje.month == dataNasc.month && hoje.day < dataNasc.day)) {
      idade--;
    }
    return idade;
  }
}
