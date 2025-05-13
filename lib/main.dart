import 'package:flutter/material.dart';
import 'view/login.dart';
import 'view/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneTrail',
      theme: darkTheme, //
      home: const LoginScreen(),
    );
  }
}
