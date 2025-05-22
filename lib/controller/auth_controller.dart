import '../models/user.dart';
import '../dao/user_dao.dart';

class AuthController {
  static final AuthController _instancia = AuthController._internal();

  AuthController._internal();

  factory AuthController() {
    return _instancia;
  }

  final UserDao _userDao = UserDao();
  User? _usuarioLogado;
  String? _emailRedefinicaoSenha;
  String? _codigoRedefinicaoSenha;

  User? get usuarioLogado => _usuarioLogado;

  bool login(String identificador, String senha) {
    for (User user in _userDao.listar) {
      if (identificador == user.email) {
        return user.validarSenha(senha);
      }
    }
    return false;
  }

  bool registrar(
    String nome,
    String dataNasc,
    String genero,
    String email,
    String senha,
  ) {
    final User novoUsuario = User(
      nome: nome,
      dataNasc: dataNasc,
      genero: genero,
      email: email,
      senha: senha,
    );
    bool cadastrou = _userDao.cadastrar(novoUsuario);
    if (cadastrou) {
      _usuarioLogado = novoUsuario;
    }
    return cadastrou;
  }

  String gerarCodigo() {
    //TODO: Gerar código de forma aleatória quando for mandar para o e-mail. Retornando valor fixo para testes
    return 'A12B34';
  }

  bool _enviarCodigoPorEmail(String email) {
    _codigoRedefinicaoSenha = gerarCodigo();
    //TODO: Enviar de fato o email com o código e retornar true se tudo der certo
    return true;
  }

  String emailRedefinicao (String email) {
    if (_userDao.email_cadastrado(email)) {
      _emailRedefinicaoSenha = email;
      if (_enviarCodigoPorEmail(email)) {
        return '';
      }
      return 'Erro ao enviar o código por e-mail. Tente novamente.';
    }
    return 'O e-mail informado não está cadastrado.';
  }

  String verificarCodigo (String codigo) {
    if (codigo == _codigoRedefinicaoSenha) {
      return '';
    }
    return 'Código inválido.';
  }

  bool alterarSenha (String novaSenha) {
    return _userDao.alterarSenha(_emailRedefinicaoSenha!, novaSenha);
  }

  void logout() {
    _usuarioLogado = null;
  }
}
