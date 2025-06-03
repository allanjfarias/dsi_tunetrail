import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primaryColor = Color(0xFF34B3F1);
  static const Color background = Color(0xFF0A0A0A);
  static const Color inputBackground = Color(0xFF666666);

  static const Color primaryLight = Color(0xFF5BC0F8);
  static const Color primaryDark = Color(0xFF1A8BC9);
  static const Color accent = Color(0xFF9435F3);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF707070);

  static const Color card = Color(0xFF2A2A2D);
  static const Color divider = Color(0xFF3D3D40);
  static const Color icon = Color(0xFFD0D0D0);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  static const Gradient primaryGradient = LinearGradient(
    colors: <Color> [primaryColor, accent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
}