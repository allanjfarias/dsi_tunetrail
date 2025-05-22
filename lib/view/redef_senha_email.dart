import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../controller/validation_controller.dart';
import 'login.dart';
import 'redef_senha_codigo.dart';

class RedefinicaoSenhaScreen extends StatefulWidget {
  const RedefinicaoSenhaScreen({super.key});

  @override
  State<RedefinicaoSenhaScreen> createState() => _RedefinicaoSenhaScreen();
}

class _RedefinicaoSenhaScreen extends State<RedefinicaoSenhaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleEnviarEmail() {
    if (_formKey.currentState!.validate()) {

      String msgErro = _authController.emailRedefinicao(_emailController.text);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (msgErro.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return const ValidarCodigoScreen();
            },
          ),
        );
      }
      else {
        // Adiciona feedback caso o envio falhe (ex: email não cadastrado)
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
                    'Informe o e-mail cadastrado',
                    Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationController.validateEmail,
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFF34B3F1), height: 30),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleEnviarEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF34B3F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Enviar código de verificação',
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
