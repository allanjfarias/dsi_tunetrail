import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xff0A0A0A),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
              _buildTextField('E-mail', Icons.mail),
              const SizedBox(height: 20),
              _buildTextField('Senha', Icons.lock, isPassword: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    // Lógica de login
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xff347FFF)
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Color(0xffF2F2F2),
                      fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: (){
                  // Navegar para a tela de recuperação de senha
                },
                child: const Text(
                  'Esqueci minha senha',
                  style: TextStyle(color: Color(0xffF2F2F2)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Não tem uma conta? ',
                    style: TextStyle(color: Color(0xffF2F2F2)),
                  ),
                  GestureDetector(
                    onTap: (){
                      // Navegar para tela de cadastro
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
              )
            ],
          ),
        ),
      ),
      ),
    );
    
  }
}

Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
  return TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xffF2F2F2)),
      prefixIcon: Icon(icon, color: Color(0xffF2F2F2)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff303131)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Color(0xff10100E),
    ),
    style: const TextStyle(color: Colors.white),
  );
}
