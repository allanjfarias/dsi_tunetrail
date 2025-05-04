import 'package:flutter/material.dart';
import 'cadastro.dart';
import '../controller/auth_controller.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
        context,
      );
      final NavigatorState navigator = Navigator.of(context);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Processando login...')),
      );

      bool sucesso = _authController.login(
        _emailController.text,
        _senhaController.text,
      );

      scaffoldMessenger.hideCurrentSnackBar();

      if (sucesso) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Login bem-sucedido!'),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Falha no login. Verifique seu e-mail e senha.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Image.asset(
                    'lib/assets/tunetrail_banner.png',
                    width: 600,
                    height: 300,
                  ),

                  _buildTextFormField(
                    'E-mail',
                    Icons.mail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu e-mail.';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor, insira um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    'Senha',
                    Icons.lock,
                    controller: _senhaController,
                    isPassword: true,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color(0xff347FFF),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Color(0xffF2F2F2),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // TODO: Navegar para a tela de recuperação de senha
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidade "Esqueci minha senha" não implementada.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Color(0xffF2F2F2)),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Não tem uma conta? ',
                        style: TextStyle(color: Color(0xffF2F2F2)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder<dynamic>(
                              pageBuilder:
                                  (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                  ) => const CadastroScreen(),
                              transitionsBuilder: (
                                BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation,
                                Widget child,
                              ) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOutQuint,
                                    ),
                                  ),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: Color(0xff6CA0DC),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffF2F2F2)),
        prefixIcon: Icon(icon, color: const Color(0xffF2F2F2)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff303131)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xff10100E),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
