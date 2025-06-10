import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/validation_controller.dart';
import 'login.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

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
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _handleCadastro() async{
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Processando cadastro...',
      style: AppTextStyles.bodyMedium(),)));

      bool sucesso = await _authController.registrar(
        _nomeController.text,
        _dataNascController.text,
        _generoController.text,
        _emailController.text,
        _senhaController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cadastro realizado com sucesso! Redirecionando para login...',
              style: AppTextStyles.bodyMedium(),
            ),
            backgroundColor: AppColors.success,
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
          SnackBar(
            content: Text(
              'Falha no cadastro. Verifique os dados ou tente um e-mail/nome de usuário diferente.',
              style: AppTextStyles.bodyMedium(),
            ),
            backgroundColor: AppColors.error,
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
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
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
                    ).copyWith(fontSize: 40),
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
                  const Divider(color: AppColors.primaryColor, height: 30),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleCadastro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Criar usuário',
                        style: AppTextStyles.button().copyWith(fontSize: 18),
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
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
        labelStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.icon),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      value: controller.text.isEmpty ? null : controller.text,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.icon),
      dropdownColor: AppColors.card,
      style: AppTextStyles.bodyLarge(),
      onChanged: (String? value) {
        controller.text = value ?? '';
      },
      items:
          items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            );
          }).toList(),
      validator: validator,
    );
  }
}
