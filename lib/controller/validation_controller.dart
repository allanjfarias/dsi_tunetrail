class ValidationController {
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome.';
    }
    return null;
  }

  static String? validateDatanasc(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor, insira sua data de nascimento.';
  }

  // 1. Verificar o formato da data (DD/MM/AAAA)
  final RegExp dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  if (!dateRegex.hasMatch(value)) {
    return 'Formato de data inválido. Use DD/MM/AAAA.';
  }

  // 2. Verificar se a data é válida
  try {
    List<String> parts = value.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    DateTime dataNascimento = DateTime(year, month, day);

    // Verificar se a data construída é igual à data original (para evitar datas inválidas)
    if (dataNascimento.day != day || dataNascimento.month != month || dataNascimento.year != year) {
      return 'Data inválida.';
    }

    // 3. Verificar se a data é no passado
    if (dataNascimento.isAfter(DateTime.now())) {
      return 'A data de nascimento deve ser no passado.';
    }

    // 4. Verificar idade mínima (exemplo: 13 anos)
    DateTime dataMinima = DateTime.now().subtract(Duration(days: 13*365)); // Aproximadamente 13 anos
    if (dataNascimento.isAfter(dataMinima)) {
      return 'Você deve ter pelo menos 13 anos.';
    }

  } catch (e) {
    return 'Data inválida.'; // Captura erros de parsing
  }

  return null; // Data válida
}

  static String? validateGenero(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu gênero.';
    }
    return null;
  }  

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome de usuário.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail.';
    }
    // Validação básica de formato de e-mail
    if (!value.contains('@') || !value.contains('.')) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha.';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número.';
    }
    if (!RegExp(r'[@$!%*?&]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial.';
    }
    return null;
  }

  static String? validateConfirmarSenha(String? value, String senha) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha.';
    }
    if (value != senha) {
      return 'As senhas não coincidem.';
    }
    return null;
  }
}