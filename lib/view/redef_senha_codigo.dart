import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import 'login.dart';
import 'redef_senha_nova_senha.dart';

class ValidarCodigoScreen extends StatefulWidget {
  const ValidarCodigoScreen({super.key});

  @override
  State<ValidarCodigoScreen> createState() => _ValidarCodigoScreen();
}

class _ValidarCodigoScreen extends State<ValidarCodigoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();

  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void _handleVerificarCodigo() {
    if (_formKey.currentState!.validate()) {

      String msgErro = _authController.verificarCodigo(_codigoController.text);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (msgErro.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return const AlterarSenhaScreen();
            },
          ),
        );
      }
      else {
        // Adiciona feedback de código inválido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msgErro),
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
          icon: Icon(Icons.arrow_back, color: Color(0xFF34B3F1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFF202022),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF202022),
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
                      color: Color(0xFF34B3F1),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Usa o ValidationController para validar o e-mail
                  _buildTextFormField(
                    'Informe o código recebido',
                    Icons.key_outlined,
                    controller: _codigoController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFF34B3F1), height: 30),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleVerificarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF34B3F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Verificar código',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return const LoginScreen();
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Retornar para a tela de login',
                      style: GoogleFonts.inter(
                        color: Color(0xFF34B3F1),
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
      cursorColor: Color(0xFF34B3F1),
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
        fillColor: Color.fromARGB(255, 102, 102, 102),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'validar_senha.dart';

class ValidarCodigoScreen extends StatelessWidget {
  final String email = '';
  final TextEditingController _codigoController = TextEditingController();

  const ValidarCodigoScreen({super.key});

  void _validarCodigo(BuildContext context) {
    String codigo = _codigoController.text;

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira o código.')),
      );
    } else {
      // Simulando a validação do código
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código validado com sucesso!')),
      );

      // Navegar para a tela de nova senha
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NovaSenha()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validar Código'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Insira o código de verificação enviado para $email:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: 'Código de Verificação',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _validarCodigo(context),
                child: Text('Validar código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
