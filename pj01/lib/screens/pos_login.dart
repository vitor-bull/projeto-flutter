import 'package:flutter/material.dart';

class PosLoginScreen extends StatelessWidget {
  const PosLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PosLogin"),
      ),
      body: SingleChildScrollView(
        
        child: ElevatedButton(
          
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text('Sair'),
        ),
      ),
    );
  }
}
