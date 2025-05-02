import 'package:intl/intl.dart';

class User {
  final String _nome;
  final DateTime _dataNasc;
  final String _genero;
  final String _email;
  final String _username;
  final String _senha;

  User({required String nome, required String dataNasc, required String genero, 
       required String email, required String username, required String senha})
    : _nome = nome,
      _dataNasc = DateFormat('dd/MM/yyyy').parse(dataNasc),
      _genero = genero,
      _email = email,
      _username = username,
      _senha = senha;

  String get nome => _nome;
  DateTime get dataNasc => _dataNasc;
  int get idade => _calcularIdade(dataNasc);
  String get genero => _genero;
  String get email => _email;
  String get username => _username;
  
  bool validarSenha(String tentativa) {
    return tentativa == _senha;
  }
  
  // Função para calcular a idade
  int _calcularIdade(DateTime dataNasc) {
    DateTime hoje = DateTime.now();
    int idade = hoje.year - dataNasc.year;
    if (hoje.month < dataNasc.month || (hoje.month == dataNasc.month && hoje.day < dataNasc.day)) {
      idade--;
    }
    return idade;
  }
}
