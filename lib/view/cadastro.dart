import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../controller/validation_controller.dart';
import 'login.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _nomeController.dispose();
    _dataNascController.dispose();
    _generoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _handleCadastro() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Processando cadastro...')));

      bool sucesso = _authController.registrar(
        _nomeController.text,
        _dataNascController.text,
        _generoController.text,
        _emailController.text,
        _usernameController.text,
        _senhaController.text,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cadastro realizado com sucesso! Redirecionando para login...',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Future<void>.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const LoginScreen();
              },
            ),
          );
        });
      } else {
        // Adiciona feedback caso o registro falhe (ex: email já existe)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Falha no cadastro. Verifique os dados ou tente um e-mail/nome de usuário diferente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff247FFF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xff0A0A0A),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xff0A0A0A),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'TuneTrail',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff247FFF),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Usa o ValidationController para validar o nome
                  _buildTextFormField(
                    'Nome',
                    Icons.person_3_outlined,
                    controller: _nomeController,
                    validator: ValidationController.validateNome,
                  ),
                  const SizedBox(height: 20),
                  // Usa o ValidationController para validar a data de nascimento
                  _buildTextFormField(
                    'Data de nascimento',
                    Icons.calendar_month,
                    controller: _dataNascController,
                    keyboardType: TextInputType.datetime,
                    validator: ValidationController.validateDatanasc,
                  ),
                  const SizedBox(height: 20),
                  // Usa o ValidationController para validar o genero
                  //_buildTextFormField('Genero', Icons.person_2_outlined, controller: _generoController, validator: ValidationController.validateGenero),
                  //const SizedBox(height: 20),
                  _buildDropdownFormField(
                    'Gênero',
                    Icons.person_outline,
                    <String>['Feminino', 'Masculino', 'Outro'],
                    _generoController,
                    ValidationController.validateGenero,
                  ),
                  const SizedBox(height: 20),
                  // Usa o ValidationController para validar o nome de usuário
                  _buildTextFormField(
                    'Nome de usuário',
                    Icons.person_2_outlined,
                    controller: _usernameController,
                    validator: ValidationController.validateUsername,
                  ),
                  const SizedBox(height: 20),
                  // Usa o ValidationController para validar o e-mail
                  _buildTextFormField(
                    'E-mail',
                    Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationController.validateEmail,
                  ),
                  const SizedBox(height: 20),
                  // Usa o ValidationController para validar a senha
                  _buildTextFormField(
                    'Senha',
                    Icons.lock_outlined,
                    controller: _senhaController,
                    isPassword: true,
                    validator: ValidationController.validateSenha,
                  ),
                  const SizedBox(height: 20),
                  // Usa o ValidationController para validar a confirmação de senha
                  _buildTextFormField(
                    'Confirmar Senha',
                    Icons.lock_outlined,
                    controller: _confirmarSenhaController,
                    isPassword: true,
                    validator:
                        (String? value) =>
                            ValidationController.validateConfirmarSenha(
                              value,
                              _senhaController.text,
                            ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.blueAccent, height: 30),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleCadastro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff247FFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Criar usuário',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffF2F2F2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Já tem uma conta? Faça login',
                      style: GoogleFonts.inter(
                        color: Color(0xff247FFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    IconData icon, {
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Color(0xffF2F2F2)),
      cursorColor: Color(0xff6CA0DC),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffF2F2F2)),
        prefixIcon: Icon(icon, color: Color(0xffF2F2F2)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff303131)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Color(0xff10100E),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildDropdownFormField(
    String label,
    IconData icon,
    List<String> items,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffF2F2F2)),
        prefixIcon: Icon(icon, color: Color(0xffF2F2F2)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff303131)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Color(0xff10100E),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      value: controller.text.isEmpty ? null : controller.text,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xffF2F2F2)),
      dropdownColor: Color(0xff10100E),
      style: const TextStyle(color: Color(0xffF2F2F2)),
      onChanged: (String? value) {
        controller.text = value ?? '';
      },
      items:
          items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Color(0xffF2F2F2)),
              ),
            );
          }).toList(),
      validator: validator,
    );
  }
}
