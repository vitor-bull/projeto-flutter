import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        // Adicionado SingleChildScrollView aqui
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 30.0, vertical: 200.0), // Removido padding vertical
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(
                      color:
                          Colors.white), // Definindo a cor do texto como branco
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nome@gmail.com',
                    labelStyle: TextStyle(
                        color: Colors
                            .white), // Definindo a cor do rótulo como branco
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .blue), // Definindo a cor da borda inferior quando focado como azul
                    ),
                  ),
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return "Digite seu e-mail";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _senhaController,
                  style: const TextStyle(
                      color:
                          Colors.white), // Definindo a cor do texto como branco
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    hintText: "Digite sua Senha",
                    labelStyle: TextStyle(
                        color: Colors
                            .white), // Definindo a cor do rótulo como branco
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .blue), // Definindo a cor da borda inferior quando focado como azul
                    ),
                  ),
                  validator: (senha) {
                    if (senha == null || senha.isEmpty) {
                      return "Digite sua Senha !";
                    } else if (senha.length <= 7) {
                      return 'A senha é de 8 caracteres';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      print("Email: ${_emailController.text}");
                      print("Senha: ${_senhaController}");

                      try {
                        var success = await logar(
                            _emailController.text, _senhaController.text);
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/posLogin');
                        } else {
                          // Handle unsuccessful login
                        }
                      } catch (e) {
                        // Exibe a mensagem de erro
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue), // Define a cor de fundo do botão
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold), // Define a cor do texto do botão
                  ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/registration');
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue), // Define a cor do texto do botão
                  ),
                  child: const Text(
                    'Ainda não tem uma conta?\nClique aqui para se cadastrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white), // Define a cor do texto do botão
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

Future<bool> logar(String email, String password) async {
  try {
    var url = Uri.parse("http://192.168.200.108:3001/users/login?apiKey=grupo8_falaAI");
    var response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );

    print('Resposta do servidor:');
    print('Status: ${response.statusCode}');
    print('Corpo: ${response.body}');

    if (response.statusCode == 200) {
      print('Login bem-sucedido');
      return true; // Login successful
    } else if (response.statusCode == 401) {
      print('Falha no login: E-mail ou senha inválida');
      throw Exception('E-mail ou senha inválida'); // Throw an exception to be handled
    } else {
      print('Erro desconhecido durante o login');
      throw Exception('Erro desconhecido'); // Throw an exception to be handled
    }
  } catch (e) {
    print('Erro ao fazer login: $e');
    throw Exception('Erro ao fazer login: $e'); // Throw an exception with detailed message
  }
}

