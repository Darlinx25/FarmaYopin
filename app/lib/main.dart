import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FarmaYopinApp());
}

class FarmaYopinApp extends StatelessWidget {
  const FarmaYopinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmaYopin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}