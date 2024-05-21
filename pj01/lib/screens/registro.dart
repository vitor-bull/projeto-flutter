import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;

  void _launchURL() async {
    const url = 'https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm';
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Cadastro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 25.0, vertical: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              TextFormField( // Novo campo de confirmação de senha
                controller: _confirmPasswordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _acceptedTerms = newValue!;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _launchURL,
                      child: const Text(
                        'Aceito os termos de serviço',
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_acceptedTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Você precisa aceitar os termos de serviço para se registrar."),
                      ),
                    );
                    return;
                  }
                  try {
                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      throw 'A senha e a confirmação de senha não coincidem';
                    }
                    var success = await register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      // Handle unsuccessful registration
                    }
                  } catch (e) {
                    // Exibe a mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'Já possui uma conta?\nClique aqui para fazer login',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> register(String name, String email, String password) async {
  final url = Uri.parse(
      'http://172.31.41.95:3001/users/register?apiKey=grupo8_falaAI');
  final body = jsonEncode({'name': name, 'email': email, 'password': password});

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    print('Resposta do servidor:');
    print('Status: ${response.statusCode}');
    print('Corpo: ${response.body}');

    if (response.statusCode == 201) {
      print('Registro bem-sucedido');
      return true;
    } else if (response.statusCode == 400) {
      throw 'Os dados fornecidos são inválidos';
    } else if (response.statusCode == 409) {
      throw 'Já existe um usuário com este e-mail';
    } else {
      throw 'Erro desconhecido durante o registro';
    }
  } catch (e) {
    throw 'Erro ao fazer registro: $e';
  }
}
