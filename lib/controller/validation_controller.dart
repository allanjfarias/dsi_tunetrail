class ValidationController {
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome.';
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
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
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