import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../controller/validation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class AlterarSenhaScreen extends StatefulWidget {
  final String recoveryCode;

  const AlterarSenhaScreen({super.key, required this.recoveryCode});

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final AuthController _authController = AuthController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<String?> lerEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  void _handleAlterarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final String? erro = await _authController.redefinirSenhaComToken(
      recoveryToken: widget.recoveryCode,
      novaSenha: _senhaController.text,
      email: await lerEmail() ?? '',
    );

    setState(() => _loading = false);

    if (!mounted) return;
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Senha alterada com sucesso! Redirecionando para login...',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF34B3F1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF202022),
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
                      color: const Color(0xFF34B3F1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    'Nova Senha',
                    Icons.lock_outlined,
                    controller: _senhaController,
                    isPassword: true,
                    validator: ValidationController.validateSenha,
                  ),
                  const SizedBox(height: 20),
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
                  const Divider(color: Color(0xFF34B3F1), height: 30),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleAlterarSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34B3F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : Text(
                                'Alterar senha',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffF2F2F2),
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
                          builder:
                              (BuildContext context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Retornar para a tela de login',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34B3F1),
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
      cursorColor: const Color(0xFF34B3F1),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffF2F2F2)),
        prefixIcon: Icon(icon, color: const Color(0xffF2F2F2)),
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
        fillColor: const Color.fromARGB(255, 102, 102, 102),
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
