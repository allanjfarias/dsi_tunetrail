import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/validation_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

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

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<void> salvarEmailReset(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<void> _handleEnviarEmail() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final String? erro = await _authController.enviarEmailRedefinicao(
        _emailController.text,
      );
      await salvarEmailReset(_emailController.text);

      if (erro == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-mail enviado! Verifique sua caixa de entrada.',
            style: AppTextStyles.bodyMedium(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            erro,
            style: AppTextStyles.bodyMedium()
            ),
            backgroundColor: AppColors.error
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
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
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
                  Text(
                    'TuneTrail',
                    style: AppTextStyles.headlineLarge(
                      color: AppColors.primaryColor,
                    ).copyWith(fontSize: 40)
                  ),
                  const SizedBox(height: 50),
                  _buildTextFormField(
                    'Informe o e-mail cadastrado',
                    Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationController.validateEmail,
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: AppColors.primaryColor, height: 30),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleEnviarEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Enviar link para redefinir senha',
                        style: AppTextStyles.button(),
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
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.primaryColor,
                      ).copyWith(fontWeight: FontWeight.w500),
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
      style: AppTextStyles.bodyLarge(),
      cursorColor: AppColors.primaryColor,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.icon),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
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
