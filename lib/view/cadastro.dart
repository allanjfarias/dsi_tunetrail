import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

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
                _buildTextField('Nome', Icons.person_2_outlined),
                const SizedBox(height: 20),
                _buildTextField('E-mail', Icons.email_outlined),
                const SizedBox(height: 20),
                _buildTextField('Senha', Icons.lock_outlined, isPassword: true),
                const SizedBox(height: 20),
                _buildTextField('Confirmar Senha', Icons.lock_outlined, isPassword: true),
                const SizedBox(height: 30),
                const Divider(color: Colors.blueAccent, height: 30),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica de cadastro
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff247FFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    ),
                    child: Text(
                      'Criar perfil',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xffF2F2F2),
                      ),
                    ),
                  ),
                ),
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
    style: const TextStyle(color: Color(0xffF2F2F2)),
    cursorColor: Color(0xff6CA0DC),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xffF2F2F2)),
      prefixIcon: Icon(icon, color: Color(0xffF2F2F2)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff303131)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2)
      ),
      filled: true,
      fillColor: Color(0xff10100E),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  );
}
