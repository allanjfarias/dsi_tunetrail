import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Constantes de cores
const Color kBackgroundColor = Color(0xFF202022);
const Color kFormBackground = Color(0xFF878787);
const Color kTextColor = Color(0xFFF2F2F2);
const Color kPrimaryColor = Color(0xFF00747C);
const Color kSecondaryColor = Color(0xFF00BBC9);

// Tema escuro
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: kBackgroundColor,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    surface: kFormBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kTextColor,
  ),
  fontFamily: GoogleFonts.inter().fontFamily,
  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: kPrimaryColor,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: kTextColor,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kTextColor,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: kTextColor,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: kBackgroundColor,
    elevation: 0,
    iconTheme: IconThemeData(color: kPrimaryColor),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kTextColor,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kFormBackground,
    labelStyle: TextStyle(color: kTextColor),
    prefixIconColor: kTextColor,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kSecondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: kBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kBackgroundColor,
    selectedItemColor: kPrimaryColor,
    unselectedItemColor: kTextColor,
  ),
);
