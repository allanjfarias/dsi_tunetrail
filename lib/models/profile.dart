import 'package:intl/intl.dart';

class Profile {
  final String nome;
  final DateTime dataNasc;
  final String genero;

  // Construtor principal recebe DateTime
  Profile({
    required this.nome,
    required this.dataNasc,
    required this.genero,
  });

  // Factory para criar Profile a partir da data em string "dd/MM/yyyy"
  factory Profile.fromStringDate({
    required String nome,
    required String dataNascString,
    required String genero,
  }) {
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dataNascString);
    return Profile(
      nome: nome,
      dataNasc: parsedDate,
      genero: genero,
    );
  }

  // Factory para criar Profile a partir do Map (JSON do Supabase)
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      nome: map['nome'],
      genero: map['genero'],
      dataNasc: DateTime.parse(map['data_nasc']),
    );
  }

  // Converte o objeto para Map para salvar no Supabase
  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'nome': nome,
      'genero': genero,
      'data_nasc': dataNasc.toIso8601String(),
    };
  }

  // Getter para calcular idade baseado na dataNasc
  int get idade => _calcularIdade(dataNasc);

  int _calcularIdade(DateTime data) {
    final DateTime hoje = DateTime.now();
    int idade = hoje.year - data.year;
    if (hoje.month < data.month || (hoje.month == data.month && hoje.day < data.day)) {
      idade--;
    }
    return idade;
  }
}
