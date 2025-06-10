import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'redef_senha_email.dart';
import '../controller/auth_controller.dart';
import '../controller/validation_controller.dart';
import 'home_screen.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

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

      bool sucesso = await _authController.login(
        _emailController.text,
        _senhaController.text,
      );

      scaffoldMessenger.hideCurrentSnackBar();

      if (sucesso) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Login bem-sucedido!'),
            backgroundColor: AppColors.success,
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
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
                    height: 320,
                  ),

                  _buildTextFormField(
                    'E-mail',
                    Icons.mail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationController.validateEmail,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    'Senha',
                    Icons.lock,
                    controller: _senhaController,
                    isPassword: true,
                    validator: ValidationController.validateSenha,
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
                        backgroundColor: AppColors.primaryColor,
                        elevation: 2,
                      ),
                      child: Text(
                        'Entrar',
                        style: AppTextStyles.headlineSmall() 
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder<dynamic>(
                          pageBuilder:
                              (
                                BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation,
                              ) => const RedefinicaoSenhaScreen(),
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
                    child: Text(
                      'Esqueci minha senha',
                      style: AppTextStyles.bodyMedium(color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Não tem uma conta? ',
                        style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
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
                        child: Text(
                          'Cadastre-se',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.primaryColor,
                          ).copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
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
      style: AppTextStyles.bodyLarge(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium(
          color: AppColors.textSecondary,
        ).copyWith(fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: AppColors.icon),
        errorStyle: AppTextStyles.bodyMedium(
          color: AppColors.error,
        ).copyWith(fontWeight: FontWeight.bold),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBackground),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
