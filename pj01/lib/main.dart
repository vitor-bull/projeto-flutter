import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/registro.dart';
import 'screens/login.dart';
import 'screens/pos_login.dart';

void main() {
  runApp(const FalaAi());
}

class FalaAi extends StatelessWidget {
  const FalaAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/registration': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/posLogin': (context) => const PosLoginScreen(),
        
      },
    );
  }
}
