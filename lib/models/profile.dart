import 'package:intl/intl.dart';

class Profile {
  final String? id;
  final String nome;
  final DateTime dataNasc;
  final String genero;
  final String? fotoUrl;

  Profile({
    required this.nome,
    required this.dataNasc,
    required this.genero,
    this.id,
    this.fotoUrl,
  });

  factory Profile.fromStringDate({
    required String nome,
    required String dataNasc,
    required String genero,
    String? id,
  }) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Profile(
      nome: nome,
      dataNasc: dateFormat.parse(dataNasc),
      genero: genero,
      id: id,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String?,
      nome: json['nome'] as String,
      dataNasc: DateTime.parse(json['data_nasc'] as String),
      genero: json['genero'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'data_nasc': DateFormat('yyyy-MM-dd').format(dataNasc),
      'genero': genero,
    };
  }

  int get idade => _calcularIdade(dataNasc);

  int _calcularIdade(DateTime data) {
    final DateTime hoje = DateTime.now();
    int idade = hoje.year - data.year;
    if (hoje.month < data.month ||
        (hoje.month == data.month && hoje.day < data.day)) {
      idade--;
    }
    return idade;
  }
}
