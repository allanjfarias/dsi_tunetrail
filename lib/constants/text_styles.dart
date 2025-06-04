import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

abstract class AppTextStyles {
  // Cabeçalhos
  static TextStyle headlineLarge ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  static TextStyle headlineMedium ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  static TextStyle headlineSmall ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  // Subtítulos
  static TextStyle subtitleLarge ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
  static TextStyle subtitleMedium ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Corpo de texto
  static TextStyle bodyLarge ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }
  static TextStyle bodyMedium ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  // Botões
  static TextStyle button ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Texto de campo
  static TextStyle inputText ({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  // Texto de dica
  static TextStyle hintText ({Color color = AppColors.textSecondary}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }
}